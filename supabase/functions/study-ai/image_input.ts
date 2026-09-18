export function parseImage(value: unknown): { mimeType: string; data: string } | null {
  if (value == null) return null;
  const image = value as Record<string, unknown>;
  if (image.mimeType !== "image/png" || typeof image.data !== "string" ||
      !image.data.length || image.data.length > 5592408 ||
      image.data.length % 4 !== 0 || !/^[A-Za-z0-9+/]+={0,2}$/.test(image.data)) {
    throw new Error("Foto inválida. Escolha outra imagem e tente novamente.");
  }
  const bytes = atob(image.data);
  if (bytes.length > 4 * 1024 * 1024 ||
      ![137, 80, 78, 71, 13, 10, 26, 10].every((b, i) => bytes.charCodeAt(i) === b)) {
    throw new Error("Foto inválida ou maior que 4 MB após preparação.");
  }
  return { mimeType: "image/png", data: image.data };
}

export function recognizedText(value: unknown): string {
  const text = (value as { text?: unknown })?.text;
  if (typeof text !== "string" || !text.trim()) {
    throw new Error("Não consegui ler texto nesta foto. Tente uma imagem mais nítida, com boa iluminação.");
  }
  if (text.length > 12000) throw new Error("A foto contém muito texto. Fotografe uma parte da página por vez.");
  return text.trim();
}
