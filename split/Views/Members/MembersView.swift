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
    @State var showDetails = false
    @State var tappedMember = Member.empty
    @Binding var tabSelection: Int
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
                    .contextMenu(menuItems: {
                        Button {
                            UIPasteboard.general.string = "Join my group on spllit!\nspllit://\(house.id)$\(house.password)"
                        } label: {
                            Text("Copy group invite link")
                        }
                        Button {
                            UIPasteboard.general.string = "\(house.id)"
                        } label: {
                            Text("Copy group ID")
                        }
                        
                        Text("Password: \(house.password)")
                        
                    })
                Spacer()
            }
            ForEach(house.members) { member in
                MemberCell(m: .constant(member))
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .onTapGesture {
                        //                                Fetch().getHouse(h: $house, inWR: .constant(false), noProf: .constant(false))
                        tappedMember = member
                        print(tappedMember)
                        if tappedMember.id == UserDefaults.standard.string(forKey: "myId")  {
                            tabSelection = 3
                        } else {
                            showDetails = true
                        }
                    }
            }
            Rectangle()
                .fill(Color.black)
                .frame(minHeight:120)
        }
        .onAppear(){
        }
        .sheet(isPresented: $showDetails, content: {
            MemberDetailsView(house: $house, member: $tappedMember, showView: $showDetails)
        })
        .onChange(of: house.members.count) { _ in
            print("COUNTCHANGE")
            Fetch().getHouse(h: $house, inWR: .constant(false), noProf: .constant(false))
        }
    }
}

struct MembersView_Previews: PreviewProvider {
    static var previews: some View {
        MembersView(house: .constant(House.placeholder), tabSelection: .constant(0))
            .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

