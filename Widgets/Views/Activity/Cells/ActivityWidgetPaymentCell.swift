//
//  ActivityPaymentCell.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-26.
//

import SwiftUI
import WidgetKit

struct ActivityWidgetPaymentCell: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var payment: Payment
    @State var showMemo = false
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Text(payment.from)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    Image(systemName: "arrow.right")
                    Text(payment.to)
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
                Spacer()
                moneyTextWidget(b: $payment.amount)
                    .font(.callout)
                    .foregroundColor(.primary)
                    .padding(2)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                Color("whiteblack")
                            )
                    )
            }
            .padding(.vertical, 6)
            
            WidgetTimeBar(unix: payment.time, white: colorScheme == .dark)
        }
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    Color("Material")
                )
    )
        
    }
}
//
struct ActivityWidgetPaymentCell_Preview: PreviewProvider {
    static var previews: some View {
        ActivityWidgetView(payments: [.placeholderr, .placeholderr, .placeholder, .placeholder, .placeholdera], limit: 5)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}


func moneyTextWidget(b: Binding<Float>, pre: String = "", post: String = "") -> Text {
    return Text("\(pre)\(b.wrappedValue < 0 ? "-" : "")$\(abs(b.wrappedValue), specifier: "%.2f")\(post)")
}
