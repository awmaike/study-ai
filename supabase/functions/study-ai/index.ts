import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

type StudyAction = "summary" | "explanation" | "quiz" | "flashcards";

function jsonResponse(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function hasValidClientKey(request: Request) {
  const provided = request.headers.get("apikey")?.trim();
  if (!provided) return false;

  try {
    const raw = Deno.env.get("SUPABASE_PUBLISHABLE_KEYS");
    if (raw) {
      const keys = Object.values(JSON.parse(raw));
      if (keys.includes(provided)) return true;
    }
  } catch (error) {
    console.error("Não foi possível ler SUPABASE_PUBLISHABLE_KEYS:", error);
  }

  const legacyAnonKey = Deno.env.get("SUPABASE_ANON_KEY");
  return provided === legacyAnonKey;
}

function buildPrompt(action: StudyAction, content: string, mode: string) {
  const base = `
Você é o motor de estudos de um aplicativo acadêmico chamado StudyAI.
Responda sempre em português do Brasil.
Use o conteúdo enviado como fonte principal e não invente informações.
Não use Markdown e devolva somente o JSON solicitado.

CONTEÚDO DO ALUNO:
${content}
`;

  if (action === "summary") {
    return `${base}
Crie um resumo didático, organizado e útil para revisão.
Retorne exatamente: {"result":"texto do resumo"}`;
  }

  if (action === "explanation") {
    const style = mode === "academic"
      ? "Explique de forma técnica e acadêmica, definindo os conceitos importantes."
      : mode === "short"
      ? "Explique de forma curta, direta e objetiva."
      : "Explique de forma simples, usando exemplos e analogias fáceis.";

    return `${base}
${style}
Retorne exatamente: {"result":"texto da explicação"}`;
  }

  if (action === "quiz") {
    return `${base}
Crie 5 perguntas de múltipla escolha baseadas somente no conteúdo.
Cada pergunta precisa ter 4 alternativas. correctIndex deve ser 0, 1, 2 ou 3.
Inclua uma explicação curta para a alternativa correta.
Retorne exatamente neste formato:
{"title":"Quiz: tema","questions":[{"question":"pergunta","options":["A","B","C","D"],"correctIndex":0,"explanation":"explicação"}]}`;
  }

  return `${base}
Crie 5 flashcards curtos e úteis para revisão.
Retorne exatamente neste formato:
{"cards":[{"front":"pergunta ou conceito","back":"resposta curta"}]}`;
}

function extractJson(text: string) {
  const clean = text
    .trim()
    .replace(/^```json\s*/i, "")
    .replace(/^```\s*/, "")
    .replace(/```$/, "")
    .trim();

  try {
    return JSON.parse(clean);
  } catch (_) {
    const first = clean.indexOf("{");
    const last = clean.lastIndexOf("}");
    if (first >= 0 && last > first) {
      return JSON.parse(clean.slice(first, last + 1));
    }
    throw new Error("O Gemini não retornou um JSON válido.");
  }
}

Deno.serve(async (request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (request.method !== "POST") {
    return jsonResponse({ error: "Use o método POST." }, 405);
  }

  if (!hasValidClientKey(request)) {
    return jsonResponse({ error: "Aplicativo não autorizado." }, 401);
  }

  try {
    const apiKey = Deno.env.get("GEMINI_API_KEY");
    const model = Deno.env.get("GEMINI_MODEL") ?? "gemini-3.5-flash-lite";

    if (!apiKey) {
      return jsonResponse(
        { error: "Configure GEMINI_API_KEY nos Secrets da Edge Function." },
        500,
      );
    }

    const body = await request.json();
    const action = body.action as StudyAction;
    const mode = String(body.mode ?? "simple");
    const rawContent = String(body.content ?? "").trim();

    if (!["summary", "explanation", "quiz", "flashcards"].includes(action)) {
      return jsonResponse({ error: "Ação inválida." }, 400);
    }

    if (rawContent.length < 30) {
      return jsonResponse({ error: "O conteúdo precisa ter pelo menos 30 caracteres." }, 400);
    }

    const prompt = buildPrompt(action, rawContent.slice(0, 14000), mode);
    const geminiUrl =
      `https://generativelanguage.googleapis.com/v1beta/models/${encodeURIComponent(model)}:generateContent`;

    const geminiResponse = await fetch(geminiUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: {
          temperature: 0.2,
          maxOutputTokens: 4096,
          responseMimeType: "application/json",
        },
      }),
    });

    if (!geminiResponse.ok) {
      const details = await geminiResponse.text();
      console.error("Gemini API:", geminiResponse.status, details);
      return jsonResponse(
        { error: `O Gemini respondeu com status ${geminiResponse.status}.` },
        502,
      );
    }

    const geminiJson = await geminiResponse.json();
    const parts = geminiJson?.candidates?.[0]?.content?.parts;
    const answer = Array.isArray(parts)
      ? parts.map((part: { text?: string }) => part.text ?? "").join("")
      : "";

    if (!answer) {
      console.error("Resposta inesperada do Gemini:", geminiJson);
      return jsonResponse({ error: "O Gemini não retornou conteúdo." }, 502);
    }

    return jsonResponse(extractJson(answer));
  } catch (error) {
    const message = error instanceof Error ? error.message : "Erro inesperado.";
    console.error(message);
    return jsonResponse({ error: message }, 400);
  }
});
