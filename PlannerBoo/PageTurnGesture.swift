import SwiftUI

struct PageTurnGesture: View {
    let onPreviousPage: () -> Void
    let onNextPage: () -> Void
    
    @State private var leftEdgeDragOffset: CGFloat = 0
    @State private var rightEdgeDragOffset: CGFloat = 0
    @State private var showLeftPageCurl = false
    @State private var showRightPageCurl = false
    @State private var showLeftHint = false
    @State private var showRightHint = false
    
    private let edgeWidth: CGFloat = 60
    private let curlThreshold: CGFloat = 30
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Left page turn area
                HStack {
                    PageTurnArea(
                        isLeft: true,
                        showHint: showLeftHint,
                        showCurl: showLeftPageCurl,
                        dragOffset: leftEdgeDragOffset
                    )
                    .frame(width: edgeWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let startX = value.startLocation.x
                                let translationX = value.translation.width
                                
                                if startX < edgeWidth && translationX > 0 {
                                    leftEdgeDragOffset = min(translationX, 100)
                                    showLeftPageCurl = leftEdgeDragOffset > 10
                                }
                            }
                            .onEnded { value in
                                if leftEdgeDragOffset > curlThreshold {
                                    onPreviousPage()
                                }
                                
                                withAnimation(.easeOut(duration: 0.3)) {
                                    leftEdgeDragOffset = 0
                                    showLeftPageCurl = false
                                }
                            }
                    )
                    .onTapGesture {
                        // Simple tap to go to previous page
                        onPreviousPage()
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showLeftHint = hovering
                        }
                    }
                    
                    Spacer()
                }
                
                // Right page turn area
                HStack {
                    Spacer()
                    
                    PageTurnArea(
                        isLeft: false,
                        showHint: showRightHint,
                        showCurl: showRightPageCurl,
                        dragOffset: abs(rightEdgeDragOffset)
                    )
                    .frame(width: edgeWidth)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let startX = value.startLocation.x
                                let translationX = value.translation.width
                                
                                if startX > geometry.size.width - edgeWidth && translationX < 0 {
                                    rightEdgeDragOffset = max(translationX, -100)
                                    showRightPageCurl = rightEdgeDragOffset < -10
                                }
                            }
                            .onEnded { value in
                                if rightEdgeDragOffset < -curlThreshold {
                                    onNextPage()
                                }
                                
                                withAnimation(.easeOut(duration: 0.3)) {
                                    rightEdgeDragOffset = 0
                                    showRightPageCurl = false
                                }
                            }
                    )
                    .onTapGesture {
                        // Simple tap to go to next page
                        onNextPage()
                    }
                    .onHover { hovering in
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showRightHint = hovering
                        }
                    }
                }
                

            }
        }
    }
}

struct PageTurnArea: View {
    let isLeft: Bool
    let showHint: Bool
    let showCurl: Bool
    let dragOffset: CGFloat
    
    var body: some View {
        ZStack {
            // Background area with subtle visual indicator
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(showHint ? 0.1 : 0.05),
                            Color.clear
                        ],
                        startPoint: isLeft ? .leading : .trailing,
                        endPoint: isLeft ? .trailing : .leading
                    )
                )
            
            // Page curl effect when dragging
            if showCurl {
                PageCurlEffect(
                    offset: dragOffset,
                    isLeftSide: isLeft
                )
            }
            
            // Navigation arrow hint
            VStack {
                Spacer()
                
                Image(systemName: isLeft ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                    .font(.title)
                    .foregroundColor(showHint ? .blue : .blue.opacity(0.6))
                    .scaleEffect(showHint ? 1.3 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: showHint)
                
                Text(isLeft ? "Previous" : "Next")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(showHint ? .blue : .blue.opacity(0.6))
                    .animation(.easeInOut(duration: 0.2), value: showHint)
                
                Spacer()
            }
            .padding(.vertical, 20)
        }
        .contentShape(Rectangle()) // Ensure the entire area is tappable
    }
}

struct PageCurlEffect: View {
    let offset: CGFloat
    let isLeftSide: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let width = geometry.size.width
                let height = geometry.size.height
                let curlAmount = offset * 0.5
                
                if isLeftSide {
                    // Left page curl
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height * 0.3),
                        control: CGPoint(x: curlAmount, y: height * 0.1)
                    )
                    path.addLine(to: CGPoint(x: width, y: height * 0.7))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: height),
                        control: CGPoint(x: curlAmount, y: height * 0.9)
                    )
                    path.closeSubpath()
                } else {
                    // Right page curl
                    path.move(to: CGPoint(x: width, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: 0, y: height * 0.3),
                        control: CGPoint(x: width - curlAmount, y: height * 0.1)
                    )
                    path.addLine(to: CGPoint(x: 0, y: height * 0.7))
                    path.addQuadCurve(
                        to: CGPoint(x: width, y: height),
                        control: CGPoint(x: width - curlAmount, y: height * 0.9)
                    )
                    path.closeSubpath()
                }
            }
            .fill(
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.15),
                        Color.black.opacity(0.08),
                        Color.clear
                    ],
                    startPoint: isLeftSide ? .leading : .trailing,
                    endPoint: isLeftSide ? .trailing : .leading
                )
            )
            .shadow(
                color: Color.black.opacity(0.3),
                radius: 8,
                x: isLeftSide ? 3 : -3,
                y: 3
            )
        }
    }
}

#Preview {
    PageTurnGesture(
        onPreviousPage: { print("Previous page") },
        onNextPage: { print("Next page") }
    )
    .frame(width: 400, height: 600)
    .background(Color.gray.opacity(0.1))
}