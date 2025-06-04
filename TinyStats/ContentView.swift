import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            TeamsView()
                .tabItem {
                    Label("Teams", systemImage: "person.3.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
    }
}
//
//  ContentView.swift
//  TinyStats
//
//  Created by Shawn Conboy on 6/4/25.
//

