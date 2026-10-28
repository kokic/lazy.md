///|
async fn main {
  let matches = @argparse.Command(
    "lazy.md",
    about="Print the titles of a lazy Markdown file, or the content of one title.",
    positionals=[
      @argparse.PositionArg(
        "file",
        about="lazy Markdown file to read",
        num_args=@argparse.ValueRange(lower=1, upper=1),
      ),
      @argparse.PositionArg(
        "title",
        about="Title whose content to print",
        num_args=@argparse.ValueRange(lower=0, upper=1),
        allow_hyphen_values=true,
      ),
    ],
  ).parse()
  let path = match matches.values.get("file") {
    Some([path, ..]) => path
    _ => abort("lazy: missing file path")
  }
  let title = match matches.values.get("title") {
    Some([title, ..]) => Some(title)
    _ => None
  }
  let text = @fs.read_file(path).text() catch {
    err => raise LazyError::ReadFailed(path~, reason="\{err}")
  }
  let document = parse_document(text)
  match title {
    Some(title) =>
      match document.sections.get(title) {
        Some(content) => @stdio.stdout.write(content)
        None => raise LazyError::TitleNotFound(title~)
      }
    None => {
      @stdio.stdout.write(document.preamble)
      for title in document.sections.keys() {
        @stdio.stdout.write("\{title}\n")
      }
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
  TitleNotFound(title~ : String)
}

///|
impl Show for LazyError with fn output(self, logger) {
  match self {
    ReadFailed(path~, reason~) => logger <+ "lazy: \{path}: \{reason}"
    TitleNotFound(title~) => logger <+ "lazy: title not found: \{title}"
  }
}
