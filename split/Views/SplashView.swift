//
//  SplashView.swift
//  split
//
//  Created by Jacob Tepperman on 2021-05-28.
//

import SwiftUI
import MessageUI

struct SplashView: View {
    @Binding var dontSplash: Bool
    @Binding var showSplash: Bool
    @State var showCore = false
    @State var result: Result<MFMailComposeResult, Error>? = nil
    @State var isShowingMailView = false
    var body: some View {
        VStack {

            HeaderText(text: "What's New")
                .overlay(
                    VStack {
                        Spacer()
                        HStack {
                            Text("v2.2.0")
                                .foregroundColor(.white)
                                .font(Font.subheadline.bold())
    //                            .padding()
                                .padding(.leading,30)
                            Spacer()
                        }
                    }
                )
                .padding(.bottom)
            ScrollView {
                HStack {
                    Spacer()
                    VStack {
                    if showCore {
                        SplashDetailsView(title: "Invite your friends", text: "Use the link button on the members page to copy an invitation to your group", image: "person.3.fill", color: .blue)
                        SplashDetailsView(title: "Post payments or requests", text: "Post payments to one person or requests from multiple people", image: "dollarsign.square", color: .green)
                        SplashDetailsView(title: "Track who owes who", text: "Check a member's page to see who they owe and who owes them", image: "note.text", color: .yellow)
                    } else {
                        HStack {
                            Text("Show main features")
                            Image(systemName: "chevron.down")
                        }
                        .foregroundColor(.white)
                        .padding()
                        
                    }
                }
                .animation(Animation.easeIn.speed(2))
                    Spacer()
                }
                .background(
                    RoundedRectangle(cornerRadius: 25.0)
                        .fill(
                            Color("DarkMaterial")
                        )
                )
                .padding(.horizontal)
                .padding(.bottom)
                .onTapGesture {
                    showCore.toggle()
            }
            
            SplashDetailsView(title: "Picture tools", text: "Easily crop, rotate, and resize your profile pictures", image: "crop.rotate", color: .purple)
                SplashDetailsView(title: "More app icons", text: "Check out all the new alternate icon collections below the profile page", image: "square.on.square.fill", color: .blue)

            }
            Spacer()
            Button(action : {
                isShowingMailView = true
            }) {
                Label(
                    title: { Text("Send Feedback") },
                    icon: { Image(systemName: "exclamationmark.bubble.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:30)
                    }
                )
                .foregroundColor(.white)
            }
            .padding(.horizontal)
            .padding(.vertical)
            Text("Disclaimer: This app does not involve any actual money or payments, it is just a way to keep track of payments in your group")
                .font(.footnote)
                .foregroundColor(Color.white.opacity(0.5))
                .padding(.horizontal)
            Button(action: {
                dontSplash = true
                UserDefaults.standard.set(true, forKey: "dontSplash")
                showSplash = false
            }, label: {
                HStack {
                    Spacer()
                    Text("Continue")
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
        }
        .onAppear(){
            UserDefaults.standard.setValue(true, forKey: "2.2.0")
        }
        .sheet(isPresented: $isShowingMailView) {
                    MailView(result: self.$result)
                }
        .animation(Animation.easeIn.speed(2))
    }
}

struct SplashDetailsView: View {
    let title: String
    let text: String
    let image: String
    var color: Color = .white
    var body: some View {
        HStack {
            Image(systemName: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(color)
                .padding()
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .font(Font.headline.bold())
                        .foregroundColor(.white)
                    
                    Text(text)
                        .font(.system(size: 14))
                        .foregroundColor(Color.white.opacity(0.5))
                }
                Spacer()
            }
            .frame(maxWidth: 250)
            
        }
        .lineLimit(2)
        .minimumScaleFactor(0.4)
        .padding(.bottom, 10)
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView(dontSplash: .constant(false), showSplash: .constant(false))
            .padding()
            .background(Color.black.edgesIgnoringSafeArea(.all))
            
    }
}
