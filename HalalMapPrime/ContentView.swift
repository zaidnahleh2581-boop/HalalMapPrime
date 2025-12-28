//
//  Created by Zaid Nahleh on 2025-12-23.
//  Updated by Zaid Nahleh on 2025-12-27.
//  Copyright © 2025 Zaid Nahleh.
//  All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.systemBackground
    }
    
    var body: some View {
        ZStack {
            
            TabView(selection: $selectedTab) {
                
                // 🗺 MAP TAB
                MapScreen()
                    .tabItem {
                        VStack {
                            Image(systemName: "map")
                            Text("Map")
                        }
                    }
                    .tag(0)
                
                // ➕ ADD STORE (Hidden because we will use custom button)
                AddStoreScreen()
                    .tabItem {
                        Text("") // نخليه فاضي
                    }
                    .tag(1)
                
                // ℹ️ MORE TAB
                MoreScreen()
                    .tabItem {
                        VStack {
                            Image(systemName: "ellipsis.circle")
                            Text("More")
                        }
                    }
                    .tag(2)
            }
            
            // 🔴 زر Add Store الدائري فوق التاب بار
            VStack {
                Spacer()
                
                Button {
                    selectedTab = 1
                } label: {
                    ZStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 68, height: 68)
                            .shadow(radius: 4)
                        
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .offset(y: -18)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
