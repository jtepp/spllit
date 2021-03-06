//
//  Main.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-24.
//

import SwiftUI

struct Main: View {
    @State var dontSplash = UserDefaults.standard.bool(forKey: "dontSplash")
    @Environment(\.scenePhase) var scenePhase
    @State var h = House.empty
    @State var member = Member.empty
    @State var inWR = ((UserDefaults.standard.value(forKey: "houseId") as? String ?? ""  == "waitingRoom") || (UserDefaults.standard.value(forKey: "houseId") as? String ?? ""  == "")) 
    @State var noProf = true
    @State var myId = UserDefaults.standard.string(forKey: "myId") ?? ""
    @State var tabSelection = 0
    @State var showInvite = false
    var body: some View {
        ZStack {
            TabsView(tabSelection: $tabSelection, house: $h, member: $member, myId: $myId, inWR: $inWR, noProf: $noProf, showInvite: $showInvite)
                .animation(.easeOut)
            //                .onAppear{
            //                    print("\n\n\n\n\ntrue\n\n\n\n\n\n")
            //                }
            //                .onDisappear{
            //                    print("\n\n\n\n\nfalse\n\n\n\n\n\n")
            //                }
            TabBar(tabSelection: $tabSelection)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear{
            
            Fetch().getHouse(h: $h, inWR: $inWR, noProf: $noProf)
        }
        .sheet(isPresented: $inWR, onDismiss: {
            Fetch().getHouse(h: $h, inWR: $inWR, noProf: $noProf)
        }) {
            if (dontSplash) {
                if (noProf) {
                    NoProfileView(m: $member, myId: $myId, show: $noProf, house: $h)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        .allowAutoDismiss(false)
                } else {
                    WaitingRoomView(h: $h, inWR: $inWR, noProf: $noProf, member: $member)
                        .background(Color.black.edgesIgnoringSafeArea(.all))
                        .allowAutoDismiss(false)
                }
            } else {
                SplashView(dontSplash: $dontSplash, showSplash: .constant(false))
                    .padding()
                    .background(Color.black.edgesIgnoringSafeArea(.all))
                    .allowAutoDismiss(false)
                    .animation(Animation.easeIn.speed(3))
            }
        }
        .onChange(of: h.id, perform: { _ in
            //            inWR = false
            //            noProf = false
            //            UserDefaults.standard.set("SIfrfcT2735XvpRCB714", forKey: "myId")
            //            UserDefaults.standard.set("TlRWEGz9GWrKBXqI9T8L", forKey: "houseId")
            //            myId = "SIfrfcT2735XvpRCB714"
            //            h.id = "TlRWEGz9GWrKBXqI9T8L"
            Fetch().getHouse(h: $h, inWR: $inWR, noProf: $noProf)
        })
        .onChange(of: scenePhase) { newPhase in
            
            if (UserDefaults.standard.string(forKey: "myId") ?? "") != "" {
                if newPhase == .inactive {
                    Fetch().updateStatus(status: false)
                } else if newPhase == .active {
                    print("LIIII \(showInvite)")
                    Fetch().updateStatus(status: true)
                    guard let name = shortcutItemToProcess?.localizedTitle as? String else {
                        print("else")
                        return
                    }
                    switch name {
                    case "Send payment":
                        tabSelection = 2
                    case "Send request":
                        tabSelection = 2
                    default:
                        tabSelection = 0
                    }
                } else if newPhase == .background {
                    Fetch().updateStatus(status: false)
                }
            }
        }
        
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        Main()
    }
}
