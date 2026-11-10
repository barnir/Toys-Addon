// ToyFinder DB pipeline — Lua syntax sanity checker (runs in the agent's TS sandbox).
// Usage: paste into run_typescript with the file list; checks bracket balance,
// function/if/do...end balance, and bad separators (",,", ";;", ",;") outside strings/comments.
// Not a full Lua parser — it catches the mistakes that actually break addons.

async function readFull(path: string) {
  let out = ""; let offset = 0; const limit = 300;
  while (true) {
    const r: any = await tools.file_system.read_file({ path, offset, limit });
    const content = typeof r === "string" ? r : r.content;
    if (!content || content.length === 0) break;
    out += content;
    if (content.split("\n").length < limit) break;
    offset += limit;
  }
  return out;
}
function lex(src: string) {
  let out = ""; let i = 0; const n = src.length;
  const blank = (s: string) => " ".repeat(s.length);
  while (i < n) {
    const c = src[i];
    if (src.substr(i, 2) === "--") {
      if (src.substr(i, 4) === "--[[") { const close = src.indexOf("]]", i + 4); if (close === -1) return { code: out, error: "long comment" }; out += blank(src.substring(i, close + 2)); i = close + 2; }
      else { let j = src.indexOf("\n", i); if (j === -1) j = n; out += blank(src.substring(i, j)); i = j; }
    } else if (c === '"' || c === "'") {
      let j = i + 1; while (j < n && src[j] !== c) { if (src[j] === "\\") j++; j++; }
      if (j >= n) return { code: out, error: "unterminated string @" + i };
      out += c + blank(src.substring(i + 1, j)) + c; i = j + 1;
    } else if (src.substr(i, 2) === "[[") {
      const close = src.indexOf("]]", i + 2); if (close === -1) return { code: out, error: "long string" };
      out += blank(src.substring(i, close + 2)); i = close + 2;
    } else { out += c; i++; }
  }
  return { code: out };
}
function check(src: string) {
  const { code, error } = lex(src);
  if (error) return { error };
  const stack: string[] = [];
  const pairs: Record<string, string> = { ")": "(", "]": "[", "}": "{" };
  for (let k = 0; k < code.length; k++) {
    const ch = code[k];
    if (ch === "(" || ch === "[" || ch === "{") stack.push(ch);
    else if (ch === ")" || ch === "]" || ch === "}") { if (stack.pop() !== pairs[ch]) return { bracketError: "@" + k }; }
  }
  if (stack.length) return { bracketError: "unclosed " + stack.join("") };
  const seps = (code.match(/,,|,\s*;|;\s*,|;;/g) || []).length;
  const counts: Record<string, number> = {};
  const re = /[A-Za-z_][A-Za-z0-9_]*/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(code)) !== null) { if (code[m.index - 1] === ".") continue; counts[m[0]] = (counts[m[0]] || 0) + 1; }
  const kw = (k: string) => counts[k] || 0;
  const r: any = { end: kw("end"), expected: kw("function") + kw("if") + kw("do"), badSeparators: seps, semicolons: (src.match(/;\s*$/gm) || []).length };
  if (r.end !== r.expected) r.kwError = true;
  return r;
}
async function main() {
  const base = "C:/Users/Francisco/Downloads/Addon WoW/ToyFinder/";
  const files = ["ToyFinder_Locales.lua", "ToyFinder_Data.lua", "ToyFinder_Database.lua", "ToyFinder_Core.lua", "ToyFinder_UI.lua", "ToyFinder_Minimap.lua"];
  const out: any = {};
  for (const f of files) out[f] = check(await readFull(base + f));
  return out;
}
