//
//  ActivityMessageCell.swift
//  split
//
//  Created by Jacob Tepperman on 2021-07-11.
//

import SwiftUI

struct ActivityMessageCell: View {
    @Binding var payment: Payment
    @State var img = ""
    var body: some View {
        HStack {
            
            if payment.by != (UserDefaults.standard.string(forKey: "myId") ?? "") {
                VStack {
                Spacer()
                b64toimg(b64: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 4)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(Color("Material"))
                    )
                    .onAppear {
                        Fetch().imgFromId(id: payment.by, img: $img)
                }
            }
            .padding(.trailing)
            }
            
            VStack {
                    HStack {
                        if payment.by == (UserDefaults.standard.string(forKey: "myId") ?? "") {
                            Spacer(minLength: 0)
                        }
                        Text(payment.memo)
                            .padding(.horizontal)
                            .padding(.bottom, 10)
                            .multilineTextAlignment(.leading)
                        if payment.by != (UserDefaults.standard.string(forKey: "myId") ?? "") {
                            Spacer(minLength: 0)
                        }
                    }
                }
                .foregroundColor(.white)
                .padding(.vertical, 2)
                .padding(.top, 6)
                .padding(.bottom, 10)
                .background(
                    CustomRoundedRect(corners: [.topLeft, .topRight, payment.by == (UserDefaults.standard.string(forKey: "myId") ?? "") ? .bottomLeft : .bottomRight],radius: 10)
                        .fill(
                            Color.blue
                        )
                )
                .overlay(
                    VStack {
                        Spacer()
                        TimeBar(unix: payment.time, white: true)
                            .padding(.horizontal,4)
                    }
            )
            if payment.by == (UserDefaults.standard.string(forKey: "myId") ?? "") {
                VStack {
                Spacer()
                b64toimg(b64: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    .shadow(radius: 4)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color("Material"))
                    )
                    .onAppear {
                        Fetch().imgFromId(id: payment.by, img: $img)
                }
            }
            .padding(.leading)
            }
        }
    }
}

struct ActivityMessageCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ActivityMessageCell(payment: .constant(.placeholderm))
        }
    }
}
