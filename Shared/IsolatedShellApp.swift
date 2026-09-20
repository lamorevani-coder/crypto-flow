import SwiftUI
import WebKit

@main
struct IsolatedShellApp: App {
    var body: some Scene {
        WindowGroup {
            SessionView()
        }
    }
}

struct SessionView: View {
    private var rootURL: URL {
        let value = Bundle.main.object(forInfoDictionaryKey: "RootURL") as? String
        return URL(string: value ?? "https://chatgpt.com")!
    }

    private var storeID: UUID {
        let value = Bundle.main.object(forInfoDictionaryKey: "StoreUUID") as? String
        return UUID(uuidString: value ?? "") ?? UUID(uuidString: "33333333-3333-4333-8333-333333333333")!
    }

    var body: some View {
        WebContainer(url: rootURL, storeID: storeID)
            .background(Color(.systemBackground))
    }
}

struct WebContainer: UIViewRepresentable {
    let url: URL
    let storeID: UUID

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.websiteDataStore = WKWebsiteDataStore(forIdentifier: storeID)
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.applicationNameForUserAgent = "SplitAI"

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        context.coordinator.webView = webView
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        weak var webView: WKWebView?

        func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
            webView.reload()
        }

        func webView(
            _ webView: WKWebView,
            createWebViewWith configuration: WKWebViewConfiguration,
            for navigationAction: WKNavigationAction,
            windowFeatures: WKWindowFeatures
        ) -> WKWebView? {
            if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
    }
}
