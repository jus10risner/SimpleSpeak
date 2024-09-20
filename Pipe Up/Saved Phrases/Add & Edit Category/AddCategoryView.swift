//
//  AddCategoryView.swift
//  Pipe Up
//
//  Created by Justin Risner on 9/19/24.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.dismiss) var dismiss
    @StateObject var draftCategory: DraftCategory
    
    init() {
        _draftCategory = StateObject(wrappedValue: DraftCategory())
    }
    
    var body: some View {
        NavigationStack {
            DraftCategoryView(draftCategory: draftCategory, isEditing: false, selectedCategory: nil)
                .navigationTitle("Add Category")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AddCategoryView()
}

enum SelectableSymbols: String, CaseIterable {
    case
    bookmark = "bookmark.fill",
    book = "book.fill",
    books = "books.vertical.fill",
    lanyard = "lanyardcard.fill",
    person = "figure.arms.open",
    twoPeople = "figure.2.arms.open",
    parentsAndChild = "figure.2.and.child.holdinghands",
    parentAndChild = "figure.and.child.holdinghands",
    sun = "sun.max.fill",
    zzz,
    moon = "moon.fill",
    hear = "heart.fill",
    star = "star.fill",
    messageBubble = "bubble.right.fill",
    phone = "phone.fill",
    creditCard = "creditcard.fill",
    puzzlePiece = "puzzlepiece.fill",
    house = "house.fill",
    bed = "bed.double.fill",
    desktopcomputer,
    airplane,
    car = "car.fill",
    train = "train.side.front.car",
    bandage = "bandage.fill",
    cross = "cross.fill",
    dog = "dog.fill",
    cat = "cat.fill",
    lizard = "lizard.fill",
    bird = "bird.fill",
    fish = "fish.fill",
    pawPrint = "pawprint.fill",
    leaf = "leaf.fill",
    handWave = "hand.wave.fill",
    gameController = "gamecontroller.fill",
    cake = "birthday.cake.fill",
    utensils = "fork.knife",
    gift = "gift.fill",
    bankNote = "banknote.fill",
    number
}
