//
//  ActivityRequestCell.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-26.
//

import SwiftUI

struct ActivityRequestCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var payment: Payment
    @State var showMemo = false
    var body: some View {
        VStack {
            GeneralRequestCell(payment: $payment, m: .constant(.empty))
            ScrollView {
                HStack {
                    Text("Request")
                        .font(Font.caption.smallCaps().weight(Font.Weight.black))
                    Spacer()
                }
                HStack {
                    Text(payment.memo)
                    Spacer()
                }
            }
            .padding(.bottom, showMemo ? 20 : 0)
            .animation(.easeIn)
            .frame(maxHeight: showMemo ? .infinity : 0)
            .frame(minHeight: showMemo ? 80 : 0)
            .foregroundColor(showMemo ? .primary : .clear)
        }
        .foregroundColor(.primary)
        .padding()
        .padding(.bottom, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    Color("Material")
                )
        )
        
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if payment.memo != "" {
                        Image(systemName:  "chevron.down")
                    }
                    Spacer()
                }
                .overlay(
                    TimeBar(unix: payment.time, white: colorScheme == .dark)
                        .padding(.horizontal, 4)
                        .offset(y: payment.memo == "" ? 8 : 12)
                )
            }
        )
        .onTapGesture {
            withAnimation {
                if payment.memo != "" {
                    showMemo.toggle()
                }
            }
        }
    }
}

struct ActivityRequestCell_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ActivityRequestCell(payment: .constant(.placeholder))
        }
        
    }
}
