//
//  HomeView.swift
//  WeatherWise
//
//  Created by Misha Vakhrushin on 14.04.2025.
//

import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel = SearchViewModel()
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.query.isEmpty {
                resultsList
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            searchField
                .padding()
        }
        .background(.bg1.opacity(0.8))
        .cornerRadius(12)
        .padding()
        .shadow(radius: 5)
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.query.isEmpty)
    }
    
    private var searchField: some View {
        TextField("Search location", text: $viewModel.query)
            .focused($isSearchFieldFocused)
            .padding(.horizontal, 36)
            .frame(height: 44)
            .background(.bg)
            .cornerRadius(8)
            .overlay(alignment: .leading) {
                Image(systemName: "magnifyingglass")
                    .padding(.leading, 12)
                    .foregroundStyle(.fg)
            }
            .overlay(alignment: .trailing) {
                if !viewModel.query.isEmpty {
                    Button {
                        viewModel.query = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.err)
                    }
                    .padding(.trailing, 12)
                }
            }
    }
    
    private var resultsList: some View {
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(viewModel.results, id: \.self) { result in
                        Button {
                            viewModel.selectCompletion(result)
                            isSearchFieldFocused = false
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(result.title)
                                    .foregroundColor(.text)
                                    .font(.headline)
                                
                                Text(result.subtitle)
                                    .foregroundColor(.text.opacity(0.5))
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Divider()
                    }
                }
            }
            .frame(maxHeight: 300)
        }
}
