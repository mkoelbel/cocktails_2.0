//
//  ContentView.swift
//  Cocktails
//
//  Created by Maria Koelbel on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    @State private var cocktailNames: [String] = []
    @State private var selectedCocktail: String = ""
    @State private var selectedIngredients: String = ""
    @State private var selectedInstructions: String = ""
    
    var body: some View {
        VStack {
            Picker("Choices", selection: $selectedCocktail) {
                ForEach(cocktailNames, id: \.self) { cocktail in
                    Text(cocktail)
                }
            }
            .font(.largeTitle)
            .pickerStyle(.menu)
            .padding()
            
            Text(selectedCocktail)
                .font(.title)
            
            Spacer()
            
            // if user has selected a cocktail, show recipe
            if !selectedCocktail.isEmpty {
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
        .onAppear{
            extractCocktailNames()
        }
    }
    
    // function to populate selectedIngredients and selectedInstructions variables from the recipes text file
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
    
    // function to extract the cocktail names from the recipes text file
    func extractCocktailNames() {
        
        if let fileURL = Bundle.main.url(forResource: "cocktail_recipes", withExtension: "txt"),
           let fileContents = try? String(contentsOf: fileURL)  {
            
            // list of individual cocktail recipes
            let recipes = fileContents.components(separatedBy: "COCKTAIL:\n")
            
            // loop through cocktail recipes
            for recipe in recipes.dropFirst() {
                let lines = recipe.components(separatedBy: "\n")
                // add name to list
                if let name = lines.first {
                    cocktailNames.append(name)
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
