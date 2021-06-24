//
//  AlternateIconButton.swift
//  split
//
//  Created by Jacob Tepperman on 2021-06-24.
//

import SwiftUI

struct AlternateIconButton: View {
    @Binding var choice: String
    var name: String
    var body: some View {
        Image(uiImage: UIImage(named: name+"@3x") ?? UIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40)
            .cornerRadius(7)
            .background(
                RoundedRectangle(cornerRadius: 9)
                .stroke((name == choice) ? Color.blue : Color.clear , lineWidth: 4)
                    .frame(width: (name == choice) ? 52 : 20, height: (name == choice) ? 52 : 20, alignment: .center)
            )
            .padding(.horizontal)
            .onTapGesture {
                choice = name
                UIApplication.shared.setAlternateIconName(name == "Default" ? nil : name)
                UserDefaults.standard.string(forKey: "alternateIcon")
            }
    }
}

struct AlternateIconButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                AlternateIconButton(choice: .constant("Default"), name: "Default")
                AlternateIconButton(choice: .constant("Default"), name: "Default-inverse")
                Spacer()
            }
            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .animation(.easeOut)
    }
}
