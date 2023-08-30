//
//  ContentView.swift
//  Cocktails
//
//  Created by Maria Koelbel on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedCocktail: String = ""
    @State private var selectedIngredients: String = ""
    @State private var selectedInstructions: String = ""
    
    struct cocktails_dictionary {
        let ingredients: [String]
        let mood: String
        let season: String
        let liqueur: String
        let instructions: String
    }

    let cocktails_list: [String: cocktails_dictionary] = [
        "Old Fashioned": cocktails_dictionary(
            ingredients: ["Whiskey",
                          "Sugar",
                          "Bitters",
                          "Maraschino cherry"],
            mood: "Hors d'oeuvres",
            season: "Winter",
            liqueur: "Whiskey",
            instructions: "Mix and enjoy!"
        ),
        "Manhattan": cocktails_dictionary(
            ingredients: ["Whiskey",
                          "Sweet Vermouth",
                          "Bitters",
                          "Maraschino cherry"],
            mood: "Hors d'oeuvres",
            season: "Winter",
            liqueur: "Whiskey",
            instructions: "Mix and enjoy!"
        )
    ]
    
    
    var body: some View {
        VStack {
            Picker("Choices", selection: $selectedCocktail) {
                ForEach(Array(cocktails_list.keys), id: \.self) { cocktail in
                    Text(cocktail)
                }
            }
            .font(.largeTitle)
            .pickerStyle(.menu)
            .padding()
            
            //            Spacer()
            
            Text(selectedCocktail)
                .font(.title)
            
            Spacer()
            
            if let cocktail = cocktails_list[selectedCocktail] {
                Text("Ingredients:\n\n")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 50)
                
                Text(selectedIngredients)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 50)
                
                Text("\n\n")
                
                Text("Instructions:\n\n")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 50)
                
                Text(selectedInstructions)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 50)
            }
            
            Spacer()
        }.onChange(of: selectedCocktail) { newValue in
            loadRecipe(for: newValue)
        }
    }
    
    // function to populate selectedIngredients and selectedInstructions variables from the cocktail_recipes.txt file
    func loadRecipe(for cocktail: String) {
        
        if let fileURL = Bundle.main.url(forResource: "cocktail_recipes", withExtension: "txt"),
           let fileContents = try? String(contentsOf: fileURL) {
            
            // list of individual cocktail recipes
            let recipes = fileContents.components(separatedBy: "COCKTAIL:\n")
            
            // loop through cocktail recipes
            for recipe in recipes.dropFirst() {
                
                let lines = recipe.components(separatedBy: "\n")
                
                // if we're at the recipe for the selected cocktail...
                if lines.first == cocktail {
                    
                    // list of recipe sections (ingredients, instructions)
                    let sections = recipe.components(separatedBy: "\n\n")
                    
                    // loop through sections
                    for section in sections.dropFirst() {
                        let lines = section.components(separatedBy: "\n")
                        // assign variables to display in app
                        if lines.first == "ingredients:" {
                            selectedIngredients = lines.dropFirst().joined(separator: "\n")
                        }
                        if lines.first == "instructions:" {
                            selectedInstructions = lines.dropFirst().joined(separator: "\n")
                        }
                    }
                    
                    // finally, exit loop (stop looping through cocktail recipes)
                    break
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// next steps:
// - ask chat GPT how to have both recipes and ingredients in the text file, and parse them appropriately


//struct ContentView: View {
//    @State private var firstThing: String = ""
//    @State private var otherThing: String = ""
//
//    var body: some View {
//        VStack{
//            Picker("Choices", selection: $firstThing) {
//                Text("item_A").tag("item_A")
//                Text("item_B").tag("item_B")
//            }
//            Text(firstThing)
//            Text(otherThing)
//        }.onChange(of: firstThing) { newValue in
//            doFunction(for: newValue)
//        }
//    }
//
//    func doFunction(for arg: String) {
//        print("ARGUMENT:", arg)
//        if arg == "item_A" {
//            otherThing = "other_item_1"
//        } else if arg == "item_B" {
//            otherThing = "other_item_2"
//        }
//    }
//}

