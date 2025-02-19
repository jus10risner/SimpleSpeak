//
//  InformationItemView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct InformationItemView: View {
    var title: String
    var subtitle: String
    var imageName: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.largeTitle)
                .foregroundColor(Color(.defaultAccent))
                .frame(width: 40)
                .padding()
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)

                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top)
    }
}

#Preview {
    InformationItemView(title: "Speak", subtitle: "Type phrases to have the app speak them out loud.", imageName: "person.wave.2.fill")
}
