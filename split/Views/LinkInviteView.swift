//
//  LinkInviteView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-06-15.
//

import SwiftUI

struct LinkInviteView: View {
    @Binding var inWR: Bool
    @Binding var noProf: Bool
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
    @State var showEdit = false
    @State var showSheet = false
    @State var choice = [Member]()
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
                        .frame(maxHeight: 400)
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
            
            VStack {
                Button(action: {
//                    showInvite = false
                    tapped = true
                    if noProf {
                        print("noprof inv")
                        showSheet = true
                        showEdit = true
                    }
                    else {
                        // if admin and house has more, show switch
                        if m.admin {
                        msg = "You have to choose a new Group admin before you leave"
                          showAlert = true
                            print("COUNTERHERE \(h.members.count)")
                        } else {
                            Fetch().switchToHouse(h: $h, m: $m, newGroup: newGroup, newPass: newPass, showAlert: $showAlert, tapped: $tapped, msg: $msg, inWR: $inWR, noProf: $noProf, showInvite: $showInvite, deleteFromHere: h.id)
                        }
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
                        .fill(tapped ? Color.gray : Color.blue)
                )
            })
            .disabled(tapped)
            
            Button(action: {
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
//                .padding(.horizontal)
//                .padding(.bottom)
            })
                
            }
            .padding()
        }
        .alert(isPresented: $showAlert, content: {
            if msg == "You have to choose a new Group admin before you leave" {
                return Alert(title: Text("Choose Admin"), message: Text(msg), primaryButton: Alert.Button.destructive(Text("Choose Admin"), action: {
                    showSheet = true
                    showEdit = false
                }), secondaryButton: Alert.Button.cancel())
            } else {
                return Alert(title: Text("Error joining group"), message: Text(msg), dismissButton: Alert.Button.default(Text("Ok"), action: {
                    showInvite = false
                }))
            }
        })
        .sheet(isPresented: $showSheet, onDismiss: {
            if !choice.isEmpty {
                Fetch().swapAdmin(m: choice.first!, h: h)
            }
            Fetch().switchToHouse(h: $h, m: $m, newGroup: newGroup, newPass: newPass, showAlert: $showAlert, tapped: $tapped, msg: $msg, inWR: $inWR, noProf: $noProf, showInvite: $showInvite, deleteFromHere: h.id)
            showInvite = false
        }, content: {
            if showEdit {
                NoProfileView(m: $m, myId: .constant(""), show: $showSheet, house: $h)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .allowAutoDismiss(false)
            } else {
                MemberPicker(show: $showSheet, house: $h, choice: $choice)
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .allowAutoDismiss(false)
            }
        })
        .onAppear{
            Fetch().returnMembers(hId: newGroup, nm: $newMembers, msg: $msg, showAlert: $showAlert)
        }
        .onChange(of: newName, perform: { _ in
            if newName == "err" {
                msg = "Group not found"
                showAlert = true
            }
        })
    }
}

struct LinkInviteView_Previews: PreviewProvider {
    static var previews: some View {
        LinkInviteView(inWR: .constant(true), noProf: .constant(false), showInvite: .constant(true), h: .constant(.placeholder), m: .constant(.placeholder), newGroup: .constant("x9vd0sduWMWT5Zv1FTAD"), newPass: .constant("pass"), newName: .constant("name"), newMembers: [.empty])
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}
