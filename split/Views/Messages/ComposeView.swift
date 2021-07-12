//
//  ComposeView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-07-11.
//

import SwiftUI
import MbSwiftUIFirstResponder

struct ComposeView: View {
    @Binding var members: [Member]
    @Binding var show: Bool
    @State var msg = ""
    @State var tagmsg = ""
    @State var showTagged = false
    @State var canTap = true
    @Binding var focus: String?

    var body: some View {
        VStack {
            TaggedView(tagmsg: $tagmsg, members: $members)
                .opacity(showTagged ? 1 : 0)
                .animation(Animation.easeOut.speed(2))
            Spacer()
            HStack {
                TextField("Message...", text: $msg)
                    .firstResponder(id: "msg", firstResponder: $focus)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                Button("Send"){
                    if canTap {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            show = false
                        }
                    }
                }
                .padding(.leading, -8)
                .padding(.trailing)
                .disabled(!canTap)
                .onChange(of: msg, perform: { _ in
                    if ((msg.components(separatedBy: " ").last ?? "").contains("@") && members.contains(where: { mem in
                        return mem.id != UserDefaults.standard.string(forKey: "myId") && mem.name.lowercased().contains((msg.components(separatedBy: " ").last ?? "").replacingOccurrences(of: "@", with: "").lowercased())
                    })) {
                        tagmsg = msg.components(separatedBy: " ").last!
                        showTagged = true
                    } else {
                        tagmsg = ""
                        showTagged = false
                    }
                })
            }
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("DarkMaterial"))
            )
            
            .shadow(radius: 10)
            Spacer()
        }
    }
}

struct ComposeView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            Text("Hello")
                .foregroundColor(.white)
                .font(.largeTitle)
                .offset(y:-100)
                .blur(radius: 10)
            ComposeView(members: .constant([.placeholder, .placeholder2, .placeholder3]), show: .constant(true), focus: .constant(""))
                .padding()
        }
        
    }
}

struct TaggedView: View {
    @Binding var tagmsg: String
    @Binding var members: [Member]
    var body: some View {
        VStack {
            ForEach(members.filter({ fm in
                return fm.id != UserDefaults.standard.string(forKey: "myId") && fm.name.lowercased().contains(tagmsg.replacingOccurrences(of: "@", with: "").lowercased())
            })) {m in
                Button {}
                    label: {
                        MemberCell(m: .constant(m))
                    }
            }
        }
        .frame(minWidth: 200)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("DarkMaterial"))
        )
    }
}

