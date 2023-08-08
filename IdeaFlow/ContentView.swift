//
//  ContentView.swift
//  IdeaFlow
//
//  Created by Ashish Dutt on 06/08/23.
//

import SwiftUI

struct ContentView: View {
    // MARK: Properties
    @State var ideas: [Idea] = [
        Idea(title: "My 1st idea", tags: [Tag(title: "My 2 new ideas")]),
        Idea(title: "My 2nd idea"),
        Idea(title: "My 2 new ideas", tags: [Tag(title: "My 1st idea")]),
        Idea(title: "My 2 friends")
    ]
    
    @State var tags: [Tag] = [
        Tag(title: "My 1st idea"),
        Tag(title: "My 2nd idea"),
        Tag(title: "My 2 new ideas"),
        Tag(title: "My 2 friends")
    ]
    
    @State var showTextField: Bool = false
    @State var suggestedString: [String] = []
    @State var ideaTitle: String = ""
    @State var showSuggestion: Bool = false
    
    var suggestedTags: [Tag] {
        if ideaTitle.contains("<>"){
            return tags
        }
        else{
            return []
        }
    }
    
    // MARK: Functions
    func createIdeaAndTag(title: String){
        let idea = Idea(title: title)
        let tag = Tag(title: title)
        tags.append(tag)
        ideas.insert(idea, at: 0)
    }
    // my new idea <>my 2
    func findIndex(_ str: String) -> Int{
        let target: Character = ">"
        if let index = str.firstIndex(of: target){
            let distance = str.distance(from: str.startIndex, to: index)
            return distance
        }
        return 0
    }
    
    func slicedString(s: String) -> String{
        let idx = findIndex(s)
        if(idx == 0){
            return ""
        }
        let substr = s[idx..<s.count].dropFirst(1)
        return String(substr)
        
    }
    
    func suggestString(_ input: String) -> [String]{
        var suggestedString = [String]()
        for tag in tags {
            let lhs = tag.title.lowercased()
            let rhs = input.lowercased()
            if(lhs.contains(rhs)){
                suggestedString.append(tag.title)
            }
        }
        return suggestedString
    }
    
    func findIdea(title: String, tag: Tag){
        for i in (0..<ideas.count){
            if ideas[i].title.lowercased() == title.lowercased(){
                ideas[i].addTag(tag)
                print(ideas[i].title)
                print(ideas[i].tags)
                print(tag.title)
            }
        }
    }
    
    func appendToIdea(str: String, suggestion: String){
        let index = findIndex(str)
        let newStr = str[0..<index-2]
        var idea = Idea(title: String(newStr))
        let tag = Tag(title: suggestion)
        idea.addTag(tag)
        ideas.insert(idea, at: 0)
        let tag2 = Tag(title: String(newStr))
        tags.append(tag2)
        findIdea(title: suggestion, tag: tag2)
    }
    
    func delete(_ index: IndexSet){
        ideas.remove(atOffsets: index)
    }
    
    // MARK: View
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                List{
                    if showTextField {
                        Section{
                            
                            TextField("Enter new idea", text: $ideaTitle)
                                .onChange(of: ideaTitle) { newValue in
                                    if(newValue.contains("<>")){
                                        showSuggestion = true
                                        suggestedString = suggestString(slicedString(s: ideaTitle))
                                    }
                                    else{
                                        showSuggestion = false
                                    }
                                }
                                .onSubmit {
                                    if !ideaTitle.isEmpty {
                                        withAnimation {
                                            createIdeaAndTag(title: ideaTitle)
                                            ideaTitle = ""
                                            showTextField = false
                                        }
                                    }
                                    else{
                                        withAnimation {
                                            showTextField = false
                                        }
                                    }
                                }
                            if showSuggestion{
                                ForEach(suggestedString, id: \.self){suggestion in
                                    Button{
                                        withAnimation {
                                            appendToIdea(str: ideaTitle, suggestion: suggestion)
                                            ideaTitle = ""
                                            showSuggestion = false
                                            showTextField = false
                                        }
                                    }label: {
                                        Text(suggestion)
                                    }
                                }
                            }
                        }
                    }
                    Section("Ideas"){
                        ForEach(ideas) { idea in
                            withAnimation {
                                ideaView(idea: idea)
                            }
                        }
                        .onDelete(perform: delete)
                    }
                }
                Button{
                    withAnimation{
                        showTextField = true
                    }
                }label: {
                    Image(systemName: "plus")
                        .font(.title.weight(.semibold))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
                .padding()
            }
            .navigationTitle("Ideaflow")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ideaView: View{
    var idea: Idea
    var body: some View{
        HStack(){
            Text(idea.title)
            Spacer()
            if(!idea.tags.isEmpty){
                HStack {
                    ForEach(idea.tags) {tag in
                        Text(tag.title)
                            .font(.system(size: 10))
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .foregroundColor(.white)
                            .background(
                                Color.blue
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            )
                    }
                }
            }
            
        }
    }
}

struct Tag: Identifiable{
    var id: String {title}
    var title: String

}

struct Idea: Identifiable{
    var id: String {title}
    var title: String
    var tags: [Tag] = []
    
    mutating func addTag(_ tag: Tag){
        self.tags.append(tag)
    }
}

extension String {
    subscript(index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }
    
    subscript(range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let endIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return self[startIndex..<endIndex]
    }
}
