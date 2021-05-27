//
//  ProfileView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-25.
//

import SwiftUI

struct ProfileView: View {
    @Binding var house: House
    @Binding var m: Member
    @State var showSignOut = false
    @State var showImagePicker = false
    @State var sourceType: UIImagePickerController.SourceType = .camera
    @State var img: UIImage?
    var body: some View {
        ScrollView {
            HeaderText(text: "Profile")
            VStack {
                b64toimg(b64: m.image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .shadow(radius: 4)
                    .overlay(
                        Menu(content: {
                            Button(action: {
                                showImagePicker = true
                                sourceType = .camera
                            }, label: {
                                Text("Take Picture")
                            })
                            Button(action: {
                                showImagePicker = true
                                sourceType = .photoLibrary
                                
                                
                            }, label: {
                                Text("Choose from Library")
                            })
                            
                        }, label: {
                            Image(systemName: "camera.fill")
                                .padding(10)
                                .foregroundColor(.black)
                                .background(
                                    Circle()
                                        .fill(
                                            Color.gray
                                        )
                                )
                        })
                        .offset(y: 100)
                    )
                Text(m.name)
                    .font(.largeTitle)
                    .bold()
                if m.admin {
                    Text("House admin")
                }
                Spacer()
                MemberPaymentInfoView(member: $m, house: $house)
                Spacer()
                Button(action: {
                    showSignOut = true
                }, label: {
                    HStack {
                        Spacer()
                        Text("Leave House")
                            .foregroundColor(.red)
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                Color.white.opacity(0.2)
                            )
                    )
                    .padding()
                })
                .alert(isPresented: $showSignOut, content: {
                    Alert(title: Text("Leave House"), message: Text("Are you sure you want to leave this house? All information connected to you will be deleted."), primaryButton: Alert.Button.destructive(Text("Confirm"), action: {
                        //signout
                    }), secondaryButton: Alert.Button.cancel())
                })
                Text("ID: \(m.id)")
                    .font(.caption)
                    .foregroundColor(Color("Secondary"))
                Spacer(minLength: 80)
            }
            .padding(.vertical, 40)
            .foregroundColor(.white)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .sheet(isPresented: $showImagePicker, content: {
                ImagePicker(img: $img, isShown: $showImagePicker, sourceType: sourceType)
            })
            .onChange(of: img, perform: { _ in
                if img != nil {
                    Fetch().updateImg(img: img!, hId: house.id, myId: m.id)
                }
            })
                        .onAppear{
                            UserDefaults.standard.set(m.id, forKey: "myId")
                        }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(house: .constant(.placeholder), m: .constant(.placeholder))
    }
}
