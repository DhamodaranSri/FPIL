//
//  SearchView.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    var searchPlaceholder: String = ""
    var body: some View {
        HStack {
            TextField(
                searchPlaceholder,
                    text: $searchText,
                    prompt: Text(searchPlaceholder).foregroundColor(.gray) // placeholder gray
                )
                .foregroundColor(.white) // search text white
                .padding()
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding()
        }
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}

struct SearchBarWithNormalAndQRView: View {
    var searchPlaceholder: String = "Search Using QR or Site Id"
    @Binding var text: String
    var onSearch: (() -> Void)? = nil
    var onQRScan: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField(
                searchPlaceholder,
                    text: $text,
                    prompt: Text(searchPlaceholder).foregroundColor(.gray) // placeholder gray
                )
                .foregroundColor(.white)
                .padding(.vertical, 8)

            // QR Button
            Button(action: {
                onQRScan?()
            }) {
                Image(systemName: "qrcode.viewfinder")
                    .foregroundColor(.appPrimary)
                    .padding(6)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            
            // Search Button
            /*
            Button(action: {
                onSearch?()
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(6)
                    .background(Color.appPrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
             */
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
        .background(Color(.applicationBGcolor))
        .cornerRadius(12)
        .contentShape(Rectangle())
        .padding(.horizontal, 10)
        
    }
}

#Preview {
    SearchBarWithNormalAndQRView(text: .constant(""))
}
