//
//  ContentView.swift
//  Cocktails
//
//  Created by Maria Koelbel on 8/15/23.
//

import SwiftUI

struct ContentView: View {
    // Variables which don't change during app session
    var fileContents: String = ""
    var recipes: [String] = []
    var cocktailNames: [String] = []
    var cocktailTagsDict: [String: [String]] = [:]
    var sortedTags: [String] = []
    
    // Variables which change during app session
    @State private var selectedCocktail: String = ""
    @State private var selectedTag: String = ""
    @State private var selectedPotentialCocktail: String = ""
    @State private var numServings = 1
    @State private var cocktailName: String = ""
    @State private var ingredients: [String] = []
    @State private var instructions: [String] = []
    @State private var isScalable: Bool = false
    
    let liquorsList = ["Gin", "Prosecco", "Rum", "Tequila", "Vodka", "Whiskey"]
    
    // Do upon opening app
    init() {
        fileContents = getTextFileContents("cocktail_recipes")!
        recipes = extractRecipes(fileContents)
        cocktailNames = compileCocktailNames(recipes)
        cocktailTagsDict = buildTagsDict(recipes)
        sortedTags = sortTags(cocktailTagsDict)
    }
    
    var body: some View {
        VStack {
            
            // Cocktails picker
            HStack(spacing: -2) {
                Text("Choose a Cocktail")
                
                Picker("Cocktails", selection: $selectedCocktail) {
                    ForEach(cocktailNames, id: \.self) { cocktail in
                        Text(cocktail)
                    }
                }
            }
            .padding(.top, 20)
            
            Text("or")
                .padding(.top, -10)
                .padding(.bottom, 2)
            
            // Descriptions picker
            HStack {
                VStack(spacing: 0) {
                    Text("Choose a Description")
                    
                    Picker("Descriptions", selection: $selectedTag) {
                        ForEach(sortedTags, id: \.self) { tag in
                            Text(tag)
                        }
                    }
                }
                .padding(.trailing, 10)
                
                // Potentional Cocktails picker
                VStack(spacing: 0) {
                    // If user has selected a tag, show picker
                    if !selectedTag.isEmpty {
                        Text("Potential Cocktails")
                        
                        Picker("Potential Cocktails", selection: $selectedPotentialCocktail) {
                            ForEach(cocktailTagsDict[selectedTag] ?? [], id: \.self) { cocktail in
                                Text(cocktail)
                            }
                        }
                    }
                }
            }
            
            // Number of Servings picker
            if isScalable {
                HStack(spacing: -2) {
                    Text("Number of servings")
                    
                    Picker("Servings", selection: $numServings) {
                        ForEach(1...10, id: \.self) { number in
                            Text("\(number)")
                        }
                    }
                }
            }
            
            // If user has selected a cocktail, show recipe
            if !cocktailName.isEmpty {
                
                Text(cocktailName)
                    .font(.title)
                    .padding([.top, .bottom], 16)
                
                Text("Ingredients:")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom, 4)
                
                ForEach(ingredients, id: \.self) { ingredient in
                    Text(ingredient)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 30)
                
                Text("Instructions:")
                    .font(.title2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .trailing], 30)
                    .padding(.bottom, 4)
                    .padding(.top, 20)
                
                ForEach(instructions, id: \.self) { instruction in
                    Text(instruction)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .trailing], 30)
            }
            
            Spacer()
            
        }
        // Do upon selecting a new cocktail
        .onChange(of: selectedCocktail) { newSelectedCocktail in
            updateDisplayForSelectedCocktail(newSelectedCocktail)
        }
        .onChange(of: selectedPotentialCocktail) { newSelectedCocktail in
            updateDisplayForSelectedCocktail(newSelectedCocktail)
        }
        // Do upon selecting a Number of Servings
        .onChange(of: numServings) { newNumServings in
            updateDisplayForNumServings(cocktailName, newNumServings)
        }
    }
    
    // Read file contents of a text file and return contents as a string
    func getTextFileContents(_ fileName: String) -> String? {
        // Get URL of file in the app's bundle
        if let fileURL = Bundle.main.url(forResource: fileName, withExtension: "txt") {
            do {
                // Read file contents into a string
                let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
                return fileContents
            } catch {
                print("Error reading file: \(error)")
                return nil
            }
        }
        return nil // file not found
    }
    
    // Given the contents of a text file as a string, split the text into separate cocktail recipes, and return them as a list of strings
    func extractRecipes(_ text: String) -> [String] {
        return text.components(separatedBy: "COCKTAIL:\n").filter { !$0.isEmpty }
    }
    
    // Return the recipe for a specified cocktail from a list of recipes
    func extractSingleRecipe(_ recipes: [String], _ cocktail: String) -> String {
        var targetRecipe: String = ""
        for recipe in recipes {
            let lines = recipe.components(separatedBy: "\n")
            if lines.first == cocktail {
                targetRecipe = recipe
                break // If we've found the recipe, then stop looping
            }
        }
        return targetRecipe
    }
    
    // Return a cocktail name given a recipe
    func extractCocktailName(_ recipe: String) -> String {
        let lines = recipe.components(separatedBy: "\n")
        return lines.first!
    }
    
    // Return a list of cocktail names given a list of recipes
    func compileCocktailNames(_ recipes: [String]) -> [String] {
        var cocktailNames: [String] = []
        for recipe in recipes {
            cocktailNames.append(extractCocktailName(recipe))
        }
        return cocktailNames
    }
    
    // Return a specified section of a recipe
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
    
    // Return a list of ingredients for a specified recipe
    func extractIngredients(_ recipe: String) -> [String] {
        let ingredients = extractRecipeSection(recipe, "ingredients:")
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        return ingredients
    }
    
    // Return a list of instructions for a specified recipe
    func extractInstructions(_ recipe: String) -> [String] {
        let instructions = extractRecipeSection(recipe, "instructions:")
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        return instructions
    }
    
    // Return a list of tags for a specified recipe
    func extractTags(_ recipe: String) -> [String] {
        let tags = extractRecipeSection(recipe, "tags:")
            .components(separatedBy: "\n")
            .filter { !$0.isEmpty }
        
        return tags
    }
    
    // Return a list of liquors that appear in a specified ingredients list
    func extractLiquors(_ ingredients: [String]) -> [String] {
        var liquorsInRecipe: [String] = []
        for ingredient in ingredients {
            for liquor in liquorsList {
                if ingredient.lowercased().range(of: liquor.lowercased()) != nil {
                    liquorsInRecipe.append(liquor)
                } else {
                }
            }
        }
        return liquorsInRecipe
    }
    
    // Return a boolean indicating whether a given recipe is scalable
    func extractScalable(_ recipe: String) -> Bool {
        let scalable = (extractRecipeSection(recipe, "scalable:") as NSString).boolValue
        return scalable
    }
    
    // Build a cocktails dictionary (tag: [cocktails list]) given a list of cocktail recipes
    func buildTagsDict(_ recipes: [String]) -> [String: [String]] {
        var tagsDict: [String: [String]] = [:]
        for recipe in recipes {
            let currentCocktail = extractCocktailName(recipe)
            let tags = extractTags(recipe)
            let ingredients = extractIngredients(recipe)
            let liquors = extractLiquors(ingredients)
            let allTags = tags + liquors
            for tag in allTags {
                tagsDict[tag, default: []].append(currentCocktail)
            }
        }
        return tagsDict
    }
    
    // Return a sorted list of cocktail tags, given the cocktail dictionary. Place liquors before other tags, and sort alphabetically within liquors and other tags
    func sortTags(_ dict: [String: [String]]) -> [String] {
        let keys = dict.keys
        var liquorTags: [String] = []
        var otherTags: [String] = []
        var sortedTags: [String] = []
        for key in keys {
            if liquorsList.contains(key) {
                liquorTags.append(key)
            } else {
                otherTags.append(key)
            }
        }
        sortedTags = liquorTags.sorted() + otherTags.sorted()
        return sortedTags
    }
    
    func scaleIngredients(_ recipe: String, _ scaleFactor: Int = 1) -> [String] {
        var scaledIngredients: [String] = []
        let ingredients = extractIngredients(recipe)
        for ingredient in ingredients {
            let scaledSingleIngredient = scaleSingleIngredient(ingredient, scaleFactor)
            scaledIngredients.append(scaledSingleIngredient)
        }
        return scaledIngredients
    }
    
    func scaleSingleIngredient(_ ingredient: String, _ scaleFactor: Int) -> String {
        var scaledIngredient = ingredient
        let splitIngredient = ingredient.split(maxSplits: 1, omittingEmptySubsequences: false) { $0 == " " }
        
        if splitIngredient.count == 2 {
            if let qtyStr = splitIngredient.first, let remainingStr = splitIngredient.last, let qtyNum = Float(qtyStr) {
                let scaledQty = qtyNum * Float(scaleFactor)
                var formattedScaledQty = String(scaledQty)
                if scaledQty == Float(Int(scaledQty)) {
                    formattedScaledQty = String(Int(scaledQty))
                }
                scaledIngredient = "\(formattedScaledQty) \(remainingStr)"
            } else {
                print("First component of ingredients couldn't be converted to Float, or components were otherwise invalid")
            }
        } else {
            print("Ingredient string was not split into exactly 2 components")
        }
        
        return (scaledIngredient)
    }
    
    // Given a cocktail, update the necessary variables to display the new cocktail recipe in the app
    func updateDisplayForSelectedCocktail(_ cocktail: String) {
        let recipe = extractSingleRecipe(recipes, cocktail)
        cocktailName = extractCocktailName(recipe)
        ingredients = extractIngredients(recipe)
        instructions = extractInstructions(recipe)
        isScalable = extractScalable(recipe)
    }
    
    // Given a number of servings, update the ingredients list to display in the app
    func updateDisplayForNumServings(_ cocktail: String, _ numServings: Int) {
        let recipe = extractSingleRecipe(recipes, cocktail)
        ingredients = scaleIngredients(recipe, numServings)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// TO DO
// - split ingredients into qty, unit, ingr
// - add input (for SOME drinks) to make a larger batch (quantity input)
// - multiply ingredients qty by input qty
