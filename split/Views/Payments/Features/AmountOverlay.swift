//
//  AmountOverlay.swift
//  split
//
//  Created by Jacob Tepperman on 2021-10-09.
//

import SwiftUI

struct AmountOverlay: View {
    @ObservedObject var amountObj: AmountObject
    @Binding var amountText: String
    @State var text = String()
    @State var showScan = false
    @State var recognizedText = ""
    var body: some View {
        VStack {
            ScrollView {
//                Text(recognizedText)
                HStack {
                    NSHeaderText(text: "Amount", space: true, clear: .constant(false), namespace: amountObj.namespace)
                    Spacer()
                    Button {
                        withAnimation {
                            if amountObj.canCloseOverlay {
                                amountObj.showOverlay = false
                            }
                        }
                        amountText = amountObj.total() == 0 ? "" : String(format: "%.2f", amountObj.total())
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                            .font(Font.body.bold())
                            .padding(4)
                            .background(
                                Circle()
                                    .fill(
                                        Color.white                                        )
                            )
                    }
                    .matchedGeometryEffect(id: "receiptbutton", in: amountObj.namespace)
                    .padding(.trailing, 10)
                }
                VStack {
                    ForEach(amountObj.values, id: \.self) { v in
                        AmountCell(amountObj: amountObj, v: v)
                    }
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("Material").opacity(amountObj.values.count > 0 ? 1 : 0))
                )
                .padding(.horizontal)
                
            }
            HStack {
                Button {
                    showScan = true
                    recognizedText = ""
                } label: {
                    Image(systemName: "camera.viewfinder")
                        .resizable()
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: 30, height: 30)
                }
                TextField("Add...", text: $text)
                    .opacity(0.5)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .matchedGeometryEffect(id: "Amountbox", in: amountObj.namespace)
                Spacer()
                Button {
                    if Float(text) ?? 0 != 0 {
                        amountObj.values.append(Float(text)!)
                        text = ""
                    }
                } label: {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .foregroundColor(Color.white.opacity(0.5))
                        .frame(width: 30, height: 30)
                }
            }
            .padding(.horizontal)
            .onChange(of: recognizedText) { _ in
                if recognizedText != "" {
                    for num in matches(for: #"\d+[. •]\d{2}"#, in: recognizedText) {
                        if Float(num) ?? 0 != 0 {
                            amountObj.values.append(Float(num)!)
                        }
                    }
                }
            }
            Button(action: {
                if amountObj.canCloseOverlay {
                    amountObj.showOverlay = false
                    amountText = amountObj.total() == 0 ? "" : String(format: "%.2f", amountObj.total())
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("Done")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue)
                )
                .padding()
            })
        }
        .background(Color("DarkMaterial").cornerRadius(10)
                        .matchedGeometryEffect(id: "background", in: amountObj.namespace))
        .padding()
        .padding(.bottom, 90)
        .matchedGeometryEffect(id: "whole", in: amountObj.namespace)
        .sheet(isPresented: $showScan, content: {
            ScanDocumentView(recognizedText: $recognizedText)
        })
    }
}

struct AmountOverlay_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            AmountOverlay(amountObj: AmountObject(Namespace().wrappedValue).placeholder(), amountText: .constant("0.00"))
        }
    }
}


func matches(for regex: String, in text: String) -> [String] {

    do {
        let regex = try NSRegularExpression(pattern: regex)
        let results = regex.matches(in: text,
                                    range: NSRange(text.startIndex..., in: text))
        return results.map {
            String(text[Range($0.range, in: text)!])
        }
    } catch let error {
        print("invalid regex: \(error.localizedDescription)")
        return []
    }
}
