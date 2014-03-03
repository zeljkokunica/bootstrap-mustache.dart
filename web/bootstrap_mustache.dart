import 'dart:html';
import 'package:mustache4dart/mustache4dart.dart' as mustache;

Map compiledTemplates = {}, 
    partials = {}; 

String partialProvider(String partialName) {
  return partials[partialName.trim()];   
}

void readTemplates() {
  String a = "a";
  compiledTemplates = {};
  List links = querySelectorAll("link[rel=import]");
  links.forEach((link){
    link.import.querySelectorAll("partial").forEach((partial){
      String partialName = partial.attributes["name"];
      if (partialName == null || partialName.isEmpty) {
          throw new Exception("Partial must have a name!");
      }
      partialName = partialName.trim();
      if (partials.containsKey(partialName)) {
        throw new Exception("Partial ${partialName} already registered! Check for duplicates...");
      }
      partials[partialName] = partial.innerHtml.trim().replaceAll("&gt;", ">");
    });
    
    link.import.querySelectorAll("template").forEach((template){
      String templateName = template.attributes["name"];
      if (templateName == null || templateName.isEmpty) {
        throw new Exception("Template must have a name!");
      }
      templateName = templateName.trim();
      if (compiledTemplates.containsKey(templateName)) {
        throw new Exception("Template ${templateName} already registered! Check for duplicates...");
      }
      compiledTemplates[templateName] = mustache.compile(template.innerHtml.trim().replaceAll("&gt;", ">"), partial: partialProvider);
    });
  });
  print("Templates: ${compiledTemplates.keys.toList()}");
  print("Partials: ${partials.keys.toList()}");
}

void main() {
  querySelector("#sample_text_id")
      ..text = "Click me!"
      ..onClick.listen(reverseText);
  readTemplates();
}

void reverseText(MouseEvent event) {
  String rendered = compiledTemplates["firstTemplate"]({"ime": "Željko", "items": ["one", "two", "three"]});
  querySelector("#sample_container_id").children.add(new Element.html(rendered));
}
