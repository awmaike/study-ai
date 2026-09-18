import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key, this.discoverCameras = availableCameras});
  final Future<List<CameraDescription>> Function() discoverCameras;
  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _index = 0;
  int _generation = 0;
  bool _loading = true;
  bool _capturing = false;
  String? _error;
  bool _suspended = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  Future<void> _open() async {
    final generation = ++_generation;
    setState(() {
      _loading = true;
      _error = null;
    });
    final previous = _controller;
    _controller = null;
    await previous?.dispose();
    CameraController? next;
    try {
      if (_cameras.isEmpty) {
        _cameras = await widget.discoverCameras();
        if (_cameras.isEmpty)
          throw CameraException('notFound', 'Nenhuma câmera disponível.');
        final back = _cameras.indexWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back);
        _index = back >= 0 ? back : 0;
      }
      if (!mounted || generation != _generation) return;
      next = CameraController(_cameras[_index], ResolutionPreset.high,
          enableAudio: false);
      await next.initialize();
      if (!mounted || generation != _generation) {
        await next.dispose();
        return;
      }
      setState(() {
        _controller = next;
        _loading = false;
      });
    } catch (error) {
      await next?.dispose();
      if (!mounted || generation != _generation) return;
      final code = error is CameraException ? error.code.toLowerCase() : '';
      setState(() {
        _loading = false;
        _error = code.contains('denied') || code.contains('restricted')
            ? 'Permita o acesso à câmera nas configurações do navegador ou dispositivo. No navegador, abra o app por HTTPS ou localhost.'
            : 'Não foi possível abrir a câmera. Confira se ela está conectada e livre para uso, ou escolha uma foto da galeria.';
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // A permission dialog can make the app inactive during initialization.
      if (_controller == null) return;
      _generation++;
      _suspended = true;
      final current = _controller;
      setState(() {
        _controller = null;
        _loading = true;
      });
      unawaited(current?.dispose());
    } else if (state == AppLifecycleState.resumed &&
        _suspended &&
        !_capturing) {
      _suspended = false;
      unawaited(_open());
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final file = await controller.takePicture();
      if (mounted) Navigator.of(context).pop(file);
    } catch (_) {
      if (mounted) {
        setState(() => _capturing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Não foi possível tirar a foto. Tente novamente.')));
      }
    }
  }

  @override
  void dispose() {
    _generation++;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Fotografar conteúdo')),
        body: SafeArea(
            child: Center(
                child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(children: [
                const Text(
                    'Enquadre a página com boa luz e deixe o texto nítido.',
                    textAlign: TextAlign.center),
                const SizedBox(height: 20),
                Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? Center(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                    const Icon(Icons.no_photography_outlined,
                                        size: 48),
                                    const SizedBox(height: 16),
                                    Text(_error!, textAlign: TextAlign.center),
                                    const SizedBox(height: 16),
                                    OutlinedButton(
                                        onPressed: _open,
                                        child: const Text('Tentar novamente')),
                                  ]))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: CameraPreview(_controller!))),
                const SizedBox(height: 20),
                Row(children: [
                  if (_cameras.length > 1)
                    IconButton(
                        tooltip: 'Trocar câmera',
                        onPressed: _loading || _capturing
                            ? null
                            : () {
                                _index = (_index + 1) % _cameras.length;
                                _open();
                              },
                        icon: const Icon(Icons.cameraswitch_outlined)),
                  Expanded(
                      child: FilledButton.icon(
                          onPressed: _loading || _error != null || _capturing
                              ? null
                              : _capture,
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: Text(
                              _capturing ? 'Capturando...' : 'Tirar foto'))),
                ]),
              ])),
        ))),
      );
}
