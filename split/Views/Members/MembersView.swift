//
//  MembersView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-25.
//

import SwiftUI
import MobileCoreServices

struct MembersView: View {
    @Binding var house: House
    @State var showMemberSheet = false
    @State var showDetails = true
    @State var showSettle = false
    @State var tappedMember = Member.empty
    @Binding var payType: Int
    @Binding var tabSelection: Int
    @State var showRemove = false
    @State var showAlert = false
    @Binding var pchoice: [Member]
    @Binding var rchoice: [Member]
    @State var settleMembers = [Member]()
    var body: some View {
        ScrollView {
            HStack {
                Text(house.name)
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                Color.gray.opacity(0.2)
                            )
                    )
                    //                        .padding(-10)
                    .padding()
                
                Spacer()
                
                Button {
                    showDetails = false
                    showSettle = true
                    showMemberSheet = true
                    Fetch().returnMembers(hId: $house.wrappedValue.id, nm: $settleMembers, msg: .constant(""), showAlert: .constant(false))
                    
                } label: {
                    Image(systemName: "arrowshape.bounce.right")
                        .font(Font.body.bold())
                        .foregroundColor(.white)
                        .padding(13)
                        .background(
                            Circle()
                                .fill(
                                    Color.gray.opacity(0.2)
                                )
                        )
                    
                }
                
                Menu {
                    
                    Button {
                        UIPasteboard.general.string = "Join my group on spllit!\nspllit://\(house.id)$\(house.password)"
                    } label: {
                        Text("Copy group invite")
                        Image(systemName: "link")
                    }
                    Button {
                        UIPasteboard.general.string = "\(house.id)"
                    } label: {
                        Text("Copy group ID")
                        Image(systemName: "doc.on.doc")
                        
                    }
                    
                    Text("Password: \(house.password)")
                    
                } label: {
                    Image(systemName: "link")
                        .font(Font.body.bold())
                        .foregroundColor(.white)
                        .padding(12)
                        .background(
                            Circle()
                                .fill(
                                    Color.gray.opacity(0.2)
                                )
                        )
                    
                }
                .padding(.trailing)
            }
            ForEach(house.members) { member in
                if member.id != UserDefaults.standard.string(forKey: "myId") && house.members.first(where: { mr in
                    return mr.id == UserDefaults.standard.string(forKey: "myId")
                })?.admin ?? false {
                    MemberCell(m: .constant(member))
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .contextMenu(menuItems: {
                            Button {
                                payType = 0
                                tabSelection = 2
                                pchoice = [member]
                            }
                            label: {
                                Text("Send payment")
                                Image(systemName: "arrow.right.circle")
                            }
                            Button {
                                payType = 1
                                tabSelection = 2
                                rchoice = [member]
                            }
                            label: {
                                Text("Send request")
                                Image(systemName: "arrow.left.circle")
                            }
                            Button {
                                tappedMember = member
                                showAlert = true
                                showRemove = false
                            } label: {
                                Text("Set as admin")
                                Image(systemName: "crown")
                            }
                            Button {
                                tappedMember = member
                                showAlert = true
                                showRemove = true
                            } label: {
                                Text("Remove from group")
                                Image(systemName: "person.badge.minus")
                            }
                            
                        })
                        .onTapGesture {
                            //                                Fetch().getHouse(h: $house, inWR: .constant(false), noProf: .constant(false))
                            tappedMember = member
                            print(tappedMember)
                            if tappedMember.id == UserDefaults.standard.string(forKey: "myId")  {
                                tabSelection = 3
                            } else {
                                showDetails = true
                                showSettle = false
                                showMemberSheet = true
                            }
                        }
                } else {
                    MemberCell(m: .constant(member))
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .contextMenu(menuItems: {
                            if member.id != UserDefaults.standard.string(forKey: "myId")  {
                                Button {
                                    payType = 0
                                    tabSelection = 2
                                    pchoice = [member]
                                }
                                label: {
                                    Text("Send payment")
                                    Image(systemName: "arrow.right.circle")
                                }
                                Button {
                                    payType = 1
                                    tabSelection = 2
                                    rchoice = [member]
                                }
                                label: {
                                    Text("Send request")
                                    Image(systemName: "arrow.left.circle")
                                }
                            }
                        })
                        .onTapGesture {
                            //                                Fetch().getHouse(h: $house, inWR: .constant(false), noProf: .constant(false))
                            tappedMember = member
                            print(tappedMember)
                            if member.id == UserDefaults.standard.string(forKey: "myId")  {
                                tabSelection = 3
                            } else {
                                showDetails = true
                                showSettle = false
                                showMemberSheet = true
                            }
                        }
                }
            }
            Rectangle()
                .fill(Color.black)
                .frame(minHeight:120)
        }
        .onAppear(){
        }
        .sheet(isPresented: $showMemberSheet, content: {
            if showDetails {
                MemberDetailsView(house: $house, member: $tappedMember, showView: $showMemberSheet)
            } else {
                QuickSettleView(h: $house, settleMembers: $settleMembers, showSheet: $showMemberSheet)
            }
        })
        .alert(isPresented: $showAlert, content: {
            if showRemove {
                return Alert(title: Text("Remove \(tappedMember.name)"), message: Text("Are you sure you want to remove \(tappedMember.name) from this group?"), primaryButton: Alert.Button.destructive(Text("Confirm"), action: {
                    Fetch().removeMember(m: tappedMember, h: $house)
                    Fetch().getHouse(h: $house, m: .constant(tappedMember), inWR: .constant(false), noProf: .constant(false))
                }), secondaryButton: Alert.Button.cancel())
                
            } else {
                return Alert(title: Text("Set \(tappedMember.name) as Group admin"), message: Text("Are you sure you want to set \(tappedMember.name) as the new Group admin? This change can only be reverted by the new admin"), primaryButton: Alert.Button.destructive(Text("Confirm"), action: {
                    Fetch().swapAdmin(m: tappedMember, h: house)
                }), secondaryButton: Alert.Button.cancel())
            }
        })
    }
}

struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
        MembersView(house: .constant(House.placeholder), payType: .constant(0), tabSelection: .constant(0), pchoice: .constant([.empty]), rchoice: .constant([.empty]))
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

