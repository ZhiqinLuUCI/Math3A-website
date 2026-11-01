-- Number mathematical environments continuously across the website.
-- Source labels may contain old numbers; this filter replaces them at render time.

local chapter_files = {
  "chapter-1.qmd",
  "chapter-2.qmd",
  "chapter-3.qmd",
  "chapter-5.qmd",
  "chapter-6.qmd",
  "chapter-7.qmd"
}

local environments = {
  example = "Example",
  theorem = "Theorem",
  definition = "Definition",
  proposition = "Proposition",
  lemma = "Lemma",
  corollary = "Corollary",
  ["numberedremark"] = "Remark"
}

local function basename(path)
  return path:match("([^/\\]+)$") or path
end

local function count_blocks(path, class_name)
  local file = io.open(path, "r")
  if not file then
    return 0
  end

  local count = 0
  for line in file:lines() do
    if line:match("^:::%s*{[^}]*%." .. class_name .. "[%s}]") then
      count = count + 1
    end
  end
  file:close()
  return count
end

local current_file = basename(quarto.doc.input_file or "")
local counters = {}

for class_name, _ in pairs(environments) do
  counters[class_name] = 0
end

for _, file in ipairs(chapter_files) do
  if file == current_file then
    break
  end
  for class_name, _ in pairs(environments) do
    counters[class_name] = counters[class_name] + count_blocks(file, class_name)
  end
end

local function numbered_label(title, number, remainder)
  return pandoc.Strong({
    pandoc.Str(title),
    pandoc.Space(),
    pandoc.Str(tostring(number) .. remainder)
  })
end

local function number_environment(div, class_name, title)
  counters[class_name] = counters[class_name] + 1
  local number = counters[class_name]
  local first_block = div.content[1]

  if first_block and (first_block.t == "Para" or first_block.t == "Plain") then
    local first_inline = first_block.content[1]
    if first_inline and first_inline.t == "Strong" then
      local label = pandoc.utils.stringify(first_inline)
      local remainder = label:match("^" .. title .. "%s+%d+(.*)$")
      if not remainder then
        remainder = label:match("^" .. title .. "(.*)$")
      end
      if remainder then
        first_block.content[1] = numbered_label(title, number, remainder)
        return div
      end
    end
  end

  table.insert(div.content, 1, pandoc.Para({
    numbered_label(title, number, ".")
  }))
  return div
end

function Div(div)
  for class_name, title in pairs(environments) do
    if div.classes:includes(class_name) then
      return number_environment(div, class_name, title)
    end
  end
  return nil
end
