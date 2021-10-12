//
//  BulkCell.swift
//  split
//
//  Created by Jacob Tepperman on 2021-10-11.
//

import SwiftUI

struct BulkCell: View {
    @ObservedObject var amountObj: AmountObject
    var m: Member
    @State var txt = ""
    var body: some View {
        HStack {
            b64toimg(b64: m.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 40, height: 40)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .shadow(radius: 4)
            Text(m.name)
            Spacer()
            TextField("0.00", text: $txt)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .opacity(0.5)
                .foregroundColor(.primary)
                .frame(maxWidth: 82)
                .onAppear {
                    if amountObj.bulkValues[m.name] ?? 0 != 0 {
                        txt = String(format: "%.2f", amountObj.bulkValues[m.name]!)
                    } else {
                        txt = ""
                    }
                }
                .onChange(of: txt, perform: { _ in
                    if Float(txt) ?? 0 != 0 {
                        amountObj.bulkValues[m.name] = Float(txt)!
                    }
                    fixBulkGhosts(amountObj)
                })
                .onChange(of: amountObj.bulkPeople, perform: { _ in
                    fixBulkGhosts(amountObj)
                })
        }
        
    }
}

struct BulkCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            PaymentView(house: .constant(.placeholder), payType: .constant(0), tabSelection: .constant(0), pchoice: .constant([.empty]), rchoice: .constant([.empty]))
        }
    }
}

func fixBulkGhosts(_ amountObj: AmountObject) {
    for k in amountObj.bulkValues.keys {
        if !amountObj.bulkPeople.contains(where: { m in
            m.name == k
        }) {
            amountObj.bulkValues.removeValue(forKey: k)
        }
    }
}
