///|
async fn main {
  let matches = @argparse.Command(
    "lazy.md",
    about="print the titles of a lazy markdown file, or the content of one or more titles.",
    positionals=[
      @argparse.PositionArg(
        "file",
        about="lazy markdown file to read",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "title",
        about="title whose content to print",
        num_args=@argparse.ValueRange(lower=0),
        allow_hyphen_values=true,
      ),
    ],
  ).parse()
  let path = match matches.values.get("file") {
    Some([path, ..]) => path
    _ => abort("lazy: missing file path")
  }
  let titles = matches.values.get("title").unwrap_or([])
  let text = @fs.read_file(path).text() catch {
    err => raise LazyError::ReadFailed(path~, reason="\{err}")
  }
  let document = parse_document(text)
  if titles.is_empty() {
    @stdio.stdout.write(document.preamble)
    @stdio.stdout.write("titles: \{document.sections.keys().join(", ")}")
  } else {
    let contents : Array[String] = []
    let missing_titles : Array[String] = []
    for title in titles {
      document.sections
      .get(title)
      .map_or_else(
        () => if !missing_titles.contains(title) { missing_titles.push(title) },
        content => contents.push(content),
      )
    }
    for i, content in contents {
      @stdio.stdout.write(content)
      if i + 1 < contents.length() && !content.has_suffix("\n") {
        @stdio.stdout.write("\n")
      }
    }
    if !missing_titles.is_empty() {
      raise LazyError::TitlesNotFound(titles=missing_titles)
    }
  }
}

///|
struct Document {
  preamble : String
  sections : Map[String, String]
}

///|
fn parse_document(text : StringView) -> Document {
  let parts = text.split("### ").to_array()
  let sections : Map[String, String] = Map([])
  for part in parts[1:] {
    let (title, content) = match part.find("\n") {
      Some(newline) =>
        (part[:newline].trim().to_owned(), part[newline + 1:].to_owned())
      None => (part.trim().to_owned(), "")
    }
    sections.set(title, content)
  }
  { preamble: parts[0].to_owned(), sections, }
}

///|
suberror LazyError {
  ReadFailed(path~ : String, reason~ : String)
  TitlesNotFound(titles~ : Array[String])
}

///|
impl Show for LazyError with fn output(self, logger) {
  match self {
    ReadFailed(path~, reason~) => logger <+ "lazy: \{path}: \{reason}"
    TitlesNotFound(titles~) =>
      logger <+ "lazy: titles not found: \{titles.join(", ")}"
  }
}
