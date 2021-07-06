//
//  TabsView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-25.
//

import SwiftUI
import WidgetKit

struct TabsView: View {
    @Binding var tabSelection: Int
    @Binding var house: House
    @Binding var member: Member
    @Binding var myId: String
    @Binding var inWR: Bool
    @Binding var noProf: Bool
    @State var showInviteAlert = false
    @State var showInviteSheet = false
    @State var newName = ""
    @State var newGroup = ""
    @State var newPass = ""
    @State var newMemberName = ""
    @Binding var engaged: Bool
    @Binding var watch: Int
    @State var pchoice = [Member]()
    @State var rchoice = [Member]()
    var body: some View {
        TabView(selection: $tabSelection,
                content:  {
                    ActivityView(house: $house, tabSelection: $tabSelection, inWR: $inWR, noProf: $noProf, m: $member)
                        .tag(0)
                    MembersView(house: $house, tabSelection: $tabSelection, pchoice: $pchoice, rchoice: $rchoice)
                        .tag(1)
                    PaymentView(house: $house, tabSelection: $tabSelection, pchoice: $pchoice, rchoice: $rchoice)
                        .tag(2)
                    ProfileView(house: $house, m: .constant($house.members.wrappedValue.first(where: { (m) -> Bool in
                        return m.id == myId
                    }) ?? Member.empty), inWR: $inWR, noProf: $noProf, showStatus: .constant($house.members.wrappedValue.first(where: { (m) -> Bool in
                        return m.id == myId
                    })?.showStatus ?? Member.empty.showStatus), newName: $newMemberName, watch: $watch, engaged: $engaged)
                        .tag(3)
                })
            .tabViewStyle(PageTabViewStyle())
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .onAppear(){
                Fetch().getHouse(h: $house, m: $member, inWR: $inWR, noProf: $noProf)
            }
            .onChange(of: inWR, perform: { (_) in
//                print("WAITING ROOM CHANGED \n\n\(member)\n\n\n\n\n")
                if inWR {
                    member = .empty
                }
                noProf = member.id == ""
            })
            .onOpenURL{ url in
                            let arr = url.absoluteString.components(separatedBy: "//")
                            if arr.count == 2 {
                                let link = arr[1]
                                
                                newGroup = String(link.split(separator: "$")[0])
                                newPass = String(link.split(separator: "$")[1])
                                Fetch().groupNameFromId(id: String(newGroup), nn:$newName)
                                if newGroup == house.id {
                                    //ALREADY
                                    showInviteAlert = true
                                } else {
                                    showInviteSheet = true
                                }
                            }
            }
            .alert(isPresented: $showInviteAlert, content: {
                Alert(title: Text("Already in this group"), message: Text("You are already a member of the group you are trying to join"), dismissButton: Alert.Button.default(Text("Ok")))
            })
            .sheet(isPresented: $showInviteSheet, onDismiss: {Fetch().getHouse(h: $house, m: $member, inWR: $inWR, noProf: $noProf)}, content: {
                LinkInviteView(inWR: $inWR, noProf: $noProf, showInvite: $showInviteSheet, h: $house, m: $member, myId: $myId, newGroup: $newGroup, newPass: $newPass, newName: $newName)
                    .background(
                        Color.black.edgesIgnoringSafeArea(.all)
                    )
            })
            .onChange(of: tabSelection) { (_) in
                Fetch().getHouse(h: $house, m: $member, inWR: $inWR, noProf: $noProf)
                print("PEARL\(member.dict())")
                newMemberName = member.name
                if tabSelection == 3 {
                    engaged = true
                } else {
                    engaged = false
                }
                Fetch().updateStatus(status: true)
                WidgetCenter.shared.reloadAllTimelines()
            }

    }
}
