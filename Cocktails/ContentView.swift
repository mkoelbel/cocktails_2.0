//
//  ContentView.swift
//  Cocktails
//
//  Created by Maria Koelbel on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    var fileContents: String = ""
    var recipes: [String] = []
    var cocktailNames: [String] = []
    var cocktailTagsDict: [String: [String]] = [:]
    
    @State private var selectedCocktail: String = ""
    @State private var selectedTag: String = ""
    @State private var selectedIngredients: String = ""
    @State private var selectedInstructions: String = ""
    
    let liqueursList = ["Gin", "Prosecco", "Tequila", "Vodka", "Whiskey"]
    
    init() {
        fileContents = getTextFileContents("cocktail_recipes")!
        recipes = extractRecipes(fileContents)
        cocktailNames = compileCocktailNames(recipes)
        cocktailTagsDict = buildTagsDict(recipes)
    }
    
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
            
            Picker("Tags", selection: $selectedTag) {
                ForEach(Array(cocktailTagsDict.keys), id: \.self) { tag in
                    Text(tag)
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
            
        }.onChange(of: selectedCocktail) { newSelectedCocktail in
            let recipe = extractSingleRecipe(recipes, newSelectedCocktail)
            selectedIngredients = extractIngredients(recipe)
            selectedInstructions = extractInstructions(recipe)
        }
    }
    
    // read file contents of a text file and return contents as a string
    func getTextFileContents(_ fileName: String) -> String? {
        // get URL of file in the app's bundle
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            do {
                // read file contents into a string
                let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                return fileContents
            } catch {
                print("Error reading file: \(error)")
                return nil
            }
        }
        return nil // file not found
    }
    
    // given the contents of a text file as a string, split the text into separate cocktail recipes, and return them as a list of strings
    func extractRecipes(_ text: String) -> [String] {
        return text.components(separatedBy: "COCKTAIL:\n").filter { !$0.isEmpty }
    }
    
    // return the recipe for a specified cocktail from a list of recipes
    func extractSingleRecipe(_ recipes: [String], _ cocktail: String) -> String {
        var targetRecipe: String = ""
        for recipe in recipes {
            let lines = recipe.components(separatedBy: "\n")
            if lines.first == cocktail {
                targetRecipe = recipe
                break // if we've found the recipe, then stop looping
            }
        }
        return targetRecipe
    }
    
    func extractCocktailName(_ recipe: String) -> String {
        let lines = recipe.components(separatedBy: "\n")
        return lines.first!
    }
    
    // return a list of cocktail names given a list of recipes
    func compileCocktailNames(_ recipes: [String]) -> [String] {
        var cocktailNames: [String] = []
        for recipe in recipes {
            cocktailNames.append(extractCocktailName(recipe))
        }
        return cocktailNames
    }
    
    // return a specified section of a recipe
    func extractRecipeSection(_ recipe: String, _ sectionName: String) -> String {
        var targetSection: String = ""
        let recipeSections = recipe.components(separatedBy: "\n\n") // e.g. ingredients, instructions, etc
        for section in recipeSections {
            let lines = section.components(separatedBy: "\n")
            if lines.first == sectionName {
                targetSection = lines.dropFirst().joined(separator: "\n")
                break
            }
        }
        return targetSection
    }
    
    func extractIngredients(_ recipe: String) -> String {
        return extractRecipeSection(recipe, "ingredients:")
    }
    
    func extractInstructions(_ recipe: String) -> String {
        return extractRecipeSection(recipe, "instructions:")
    }
    
    // build a cocktails dictionary (tag: [cocktails list]) given a list of cocktail recipes
    func buildTagsDict(_ recipes: [String]) -> [String: [String]] {
        var tagsDict: [String: [String]] = [:]
        for recipe in recipes {
            let currentCocktail = extractCocktailName(recipe)
            let tags = extractRecipeSection(recipe, "tags:")
                .components(separatedBy: "\n")
                .filter { !$0.isEmpty }
            let ingredients = extractIngredients(recipe)
                .components(separatedBy: "\n")
            print("INGREDIENTS:", ingredients)
            let liqueurs = extractLiqueurs(ingredients)
            print("LIQUEURS:",liqueurs)
            let liqueursAndTags = liqueurs + tags
            print("LIQUEURS+TAGS:", liqueursAndTags)
            for tag in tags {
                tagsDict[tag, default: []].append(currentCocktail)
            }
        }
        return tagsDict
    }
    
    func extractLiqueurs(_ ingredients: [String]) -> [String] {
        var liqueurs: [String] = []
        for ingredient in ingredients {
            if liqueursList.contains(ingredient) {
                liqueurs.append(ingredient)
            }
        }
        return liqueurs
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// to do:
// - finish implementing thing where we use a function to grab the liqueurs, rather than specifying them as tags
//   - fix extractLiqueur funtion, to use regular expressions. it doesn't work at all right now
//   - modify buildDict function to sort the tags nicely
