import assert from "node:assert/strict";
import { test } from "node:test";
import { validateQuiz, parseQuizSettings, quizInstructions } from "./quiz.ts";
import { isStudyTopic } from "./study_input.ts";

const content = "O calor do Sol provoca a evaporação da água de rios e oceanos.";
const valid = () => ({
  title: "Quiz: ciclo da água",
  questions: [{
    question: "Qual processo é provocado pelo calor do Sol?",
    options: ["Condensação", "Evaporação", "Precipitação", "Infiltração"],
    correctIndex: 1, explanation: content, sourceQuote: content,
  }],
});

test("temas geram exatamente dez questões sem citações inventadas", () => {
  const quiz = valid();
  quiz.questions = Array.from({ length: 10 }, (_, i) => ({
    ...valid().questions[0], question: `Questão ${i}`, sourceQuote: "",
  }));
  assert.equal(validateQuiz(quiz, "Valorant", true), quiz);
  assert.throws(() => validateQuiz(quiz, content));
  quiz.questions.pop();
  assert.throws(() => validateQuiz(quiz, "Valorant", true));
});

test("diferencia palavra ou título de texto e entrada vazia", () => {
  for (const topic of ["Valorant", "IA", "Revolução Industrial", "  C++  "]) {
    assert.equal(isStudyTopic(topic), true);
  }
  for (const text of ["", "  ", content, "Um título\nUm parágrafo"]) {
    assert.equal(isStudyTopic(text), false);
  }
});

test("configura quantidade e dificuldade sem aceitar valores arbitrários", () => {
  assert.deepEqual(parseQuizSettings({}), {questionCount: 10, difficulty: 'medium'});
  for (const count of [5, 10, 15]) {
    assert.deepEqual(parseQuizSettings({questionCount: count, difficulty: 'hard'}), {questionCount: count, difficulty: 'hard'});
    const quiz = valid();
    quiz.questions = Array.from({length: count}, (_, i) => ({...valid().questions[0], question: `Q ${i}`, sourceQuote: ''}));
    assert.equal(validateQuiz(quiz, 'Flutter', true, count), quiz);
    assert.match(quizInstructions(true, count, 'hard'), new RegExp(`exatamente ${count}`));
    assert.match(quizInstructions(true, count, 'hard'), /AVANÇADO/);
  }
  assert.throws(() => parseQuizSettings({questionCount: 100}));
  assert.throws(() => parseQuizSettings({difficulty: 'ignore rules'}));
});

test("aceita pergunta apoiada em trecho do texto, inclusive texto curto", () => {
  const quiz = valid();
  assert.equal(validateQuiz(quiz, content), quiz);
});

test("rejeita citação inventada, alternativas repetidas e gabarito inválido", () => {
  const quote = valid();
  quote.questions[0].sourceQuote = "As plantas liberam vapor pela transpiração.";
  const options = valid();
  options.questions[0].options[0] = " evaporação ";
  const index = valid();
  index.questions[0].correctIndex = 4;
  const repeated = valid();
  repeated.questions.push(repeated.questions[0]);
  for (const quiz of [quote, options, index, repeated, {}, null, { title: 'Quiz', questions: [] }]) {
    assert.throws(() => validateQuiz(quiz, content));
  }
});
