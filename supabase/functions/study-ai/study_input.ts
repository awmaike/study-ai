export function isStudyTopic(content: string) {
  const trimmed = content.trim();
  return trimmed.length > 0 && trimmed.split(/\s+/).length <= 12 &&
    !/[.!?\n\r]/.test(trimmed);
}
