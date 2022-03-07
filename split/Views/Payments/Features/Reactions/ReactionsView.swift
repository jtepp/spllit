//
//  ReactionsView.swift
//  split
//
//  Created by Jacob Tepperman on 2022-03-07.
//

import SwiftUI

struct ReactionsView: View {
    @Binding var payment: Payment
    var reactionOptions = ["liked", "disliked", "questioned"]
    var body: some View {
        HStack(spacing:0) {
            //            ReactionsCompactLabel(title: "1", systemName: "heart.fill")
            HStack(spacing: 0) {
                if yourReaction(reactions: payment.editLog.filter({ (key: String, _: String) in
                    return !key.isNumeric
                }), memberID: (UserDefaults.standard.string(forKey: "myId") ?? "")) == "none" {
                    Text("+")
                    if payment.editLog.contains(where: { (key: String, _: String) in
                        return !key.isNumeric
                    }) {
                        Text("|")
                            .padding(.leading, 2)
                    }
                }
            }
            .padding(.top, -2)
            ForEach(reactionOptions, id: \.self) { reactionOption in
                if countReaction(reactionOption, reactions: payment.editLog.filter({ (key: String, _: String) in
                    return !key.isNumeric
                })) > 0 {
                    ReactionsCompactLabel(title: String(countReaction(reactionOption, reactions: payment.editLog.filter({ (key: String, _: String) in
                        return !key.isNumeric
                    }))), systemName: reactionToImageName(reactionOption))
                        .scaleEffect(0.75)
                }
            }
        }
        .font(.caption2)
        .foregroundColor(.white)
        .padding(.horizontal, 2)
        .background(
            Capsule()
                .fill(Color("DarkMaterial"))
        )
        .padding(2)
    }
}

struct ReactionsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            ScrollView {
                ForEach(Range(0...4)) { _ in
                    ActivityPaymentCell(payment: .constant(.placeholder), mems: [Member]())
                }
            }
        }
    }
}


func countReaction(_ reactionName: String, reactions: [String: String]) -> Int {
    return reactions.reduce(0) { $0 + ($1.value == reactionName ? 1 : 0)}
}

func yourReaction(reactions: [String: String], memberID: String) -> String {
    return reactions.first { (key: String, _: String) in
        key == memberID
    }?.value ?? "none"
}

func reactionToImageName(_ reaction: String) -> String {
    switch(reaction) {
    case "liked": return "heart.fill"
    case "disliked": return "hand.thumbsdown.fill"
    case "questioned": return "questionmark"
    default: return ""
    }
}
