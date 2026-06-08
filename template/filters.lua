-- Pandoc Lua filter: classify callout boxes and key takeaways
-- Runs at build time so wkhtmltopdf sees plain HTML with CSS classes.

-- Convert blockquotes → divs with callout classes based on emoji
function BlockQuote(el)
  local text = pandoc.utils.stringify(el)
  local classes = {"callout"}
  -- 💡 U+1F4A1 → F0 9F 92 A1
  if text:find("\xf0\x9f\x92\xa1") then
    table.insert(classes, "callout-tip")
  -- ⚠ U+26A0 → E2 9A A0
  elseif text:find("\xe2\x9a\xa0") then
    table.insert(classes, "callout-warning")
  -- 😄 U+1F604 → F0 9F 98 84
  elseif text:find("\xf0\x9f\x98\x84") then
    table.insert(classes, "callout-realtalk")
  end
  return pandoc.Div(el.content, pandoc.Attr("", classes, {}))
end

-- Mark "Key Takeaways" h3 and wrap the following bullet list
function Blocks(blocks)
  local out = pandoc.List()
  local i = 1
  while i <= #blocks do
    local b = blocks[i]
    if b.t == "Header" and b.level == 3
        and pandoc.utils.stringify(b):find("Key Takeaways") then
      b.classes:insert("key-takeaways-heading")
      out:insert(b)
      i = i + 1
      if i <= #blocks and blocks[i].t == "BulletList" then
        out:insert(pandoc.Div(
          {blocks[i]},
          pandoc.Attr("", {"key-takeaways-list"}, {})
        ))
        i = i + 1
      end
    else
      out:insert(b)
      i = i + 1
    end
  end
  return out
end
