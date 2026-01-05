//
//  InformationItemView.swift
//  SimpleSpeak
//
//  Created by Justin Risner on 10/21/24.
//

import SwiftUI

struct InformationItemView: View {
    var title: String
    var description: String
    var imageName: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundColor(Color(.accent))
                .symbolRenderingMode(.monochrome)
                .frame(width: 36, alignment: .center)
                .padding(.trailing, 8)
                .accessibility(hidden: true)

            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .accessibility(addTraits: .isHeader)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .layoutPriority(1)
        }
    }
}

#Preview {
    InformationItemView(title: "Speak", description: "Type phrases to have the app speak them out loud.", imageName: "person.wave.2.fill")
}
