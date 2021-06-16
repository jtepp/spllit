//
//  LinkInviteView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-06-15.
//

import SwiftUI

struct LinkInviteView: View {
    @Binding var inWR: Bool
    @Binding var showInvite: Bool
    @Binding var h: House
    @Binding var m: Member
    @Binding var newGroup: String
    @Binding var newPass: String
    @Binding var newName: String
    @State var showAlert = false
    @State var tapped = false
    @State var newMembers = [Member]()
    @State var msg = ""
    var body: some View {
        VStack{
            HeaderText(text: "Invitation to join")
            HStack {
                Text(newName)
                    .font(Font.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                Color.gray.opacity(0.2)
                            )
                    )
                
                Spacer()
            }
            .padding(.leading)
            .padding(.top, -20)
            Spacer()
            ScrollView {
                ForEach(newMembers) { member in
                    MemberCell(m: .constant(member))
                }
            }
            //            .frame(maxHeight: 300)
            .padding()
            //            .padding(.bottom, 10)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        Color.white.opacity(0.2)
                    )
            )
            .padding(.vertical)
            Spacer()
            Button(action: {
                /**** not in house ****/
                if h.id == "" {
                //if no my id
                /*
                     - open account maker to set to $m, join house on accept
                */
                    
                //if has id (easy)
                /*
                     - join!
                */
                
                /****in house ****/
                } else {
                    //not admin
                    
                    //if already in house and admin
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("Join")
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
            Button(action: {
                inWR = false
                showInvite = false
            }, label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.2))
                )
                .padding(.horizontal)
                .padding(.bottom)
            })
        }
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Error joining group"), message: Text(msg))
        })
        .onAppear{
            Fetch().returnMembers(hId: newGroup, nm: $newMembers)
        }
    }
}

struct LinkInviteView_Previews: PreviewProvider {
    static var previews: some View {
        LinkInviteView(inWR: .constant(true), showInvite: .constant(true), h: .constant(.placeholder), m: .constant(.placeholder), newGroup: .constant("x9vd0sduWMWT5Zv1FTAD"), newPass: .constant("pass"), newName: .constant("name"), newMembers: [.empty])
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
