import Foundation
import WebKit
import ArgumentParser

public enum Status {
    case printing
    case complete
}

// All of this changes in OS X 10.16/11 when WebKit is formally replaced by
// WKWebKit and WKWebKit.WebView finally gets a createPDF method...
// https://developer.apple.com/documentation/webkit/wkwebview/3650490-createpdf

class WebViewDelegate: NSObject, WebFrameLoadDelegate {
    
    public var dpi: CGFloat = 72.0
    public var margin: CGFloat = 1.0
    public var width: CGFloat = 6.0
    public var height: CGFloat = 9.0
    public var target: URL!
    
    private var destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private var filename: String = "webster.pdf"
    
    override init() {
        target = destination.appendingPathComponent(filename)
    }
    
    func webView(_ sender: WebView!, didFinishLoadFor frame: WebFrame!) {
        
        defer {
            NotificationCenter.default.post(name: Notification.Name("status"), object: Status.complete)
        }
                    
        let printOpts: [NSPrintInfo.AttributeKey : Any] = [
            NSPrintInfo.AttributeKey.jobDisposition : NSPrintInfo.JobDisposition.save,
            NSPrintInfo.AttributeKey.jobSavingURL   : target!
        ]
                
        let printInfo: NSPrintInfo = NSPrintInfo(dictionary: printOpts)
        let baseMargin: CGFloat    = margin * dpi
        
        printInfo.paperSize    = NSMakeSize(width * dpi, height * dpi)
        printInfo.topMargin    = baseMargin
        printInfo.leftMargin   = baseMargin
        printInfo.rightMargin  = baseMargin
        printInfo.bottomMargin = baseMargin
        
        let printOp: NSPrintOperation = NSPrintOperation(view: sender.mainFrame.frameView.documentView, printInfo: printInfo)
        
        printOp.showsPrintPanel = false
        printOp.showsProgressPanel = false
        printOp.run()
    }
}
   
struct Webster: ParsableCommand {
    
    @Argument(help: "The URL you want to generate a PDF from.")
    var url: String
    
    @Option(help: "The DPI (dots per inch) of your output document.")
    var dpi: Double = 72.0
    
    @Option(help: "The width (in inches) of your document.")
    var width: Double = 8.5
    
    @Option(help: "The height (in inches) of your document.")
    var height: Double = 11.0
    
    @Option(help: "The margin (in inches) for each page in your document.")
    var margin: Double = 1.0
    
    @Option(help: "The path where your PDF document will be created. Default is 'webster.pdf' in the current user's Documents folder.")
    var filename: String = ""
    
    func run() {
                
        guard let myURL = URL(string: url) else {
            fatalError("Invalid URL")
        }
                
        let webView = WebView()
        
        let delegate = WebViewDelegate()
        delegate.dpi = CGFloat(dpi)
        delegate.width = CGFloat(width)
        delegate.height = CGFloat(height)
        delegate.margin = CGFloat(margin)
        
        if filename != "" {
            
            guard let target = URL(string: filename) else {
                fatalError("Invalid filename")
            }
            
            delegate.target = target
        }
        
        webView.frameLoadDelegate = delegate
        
        webView.frame = NSRect(x: 0.0, y: 0.0, width: 800, height: 640)
        webView.mainFrame.load(URLRequest(url: myURL))
        
        //This little bit gets us a runloop and spins it. Otherwise nothing above here works.
        
        var working = true
        let runloop = RunLoop.current
           
        NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: "status"),
                                               object: nil,
                                               queue: .main) { (notification) in
            
            let status = notification.object as! Status

            switch status {
            case Status.complete:
                    working = false
            default:
                ()
            }
        }
        
        while working && runloop.run(mode: .default, before: .distantFuture) {
            
        }
        
        print(delegate.target.absoluteString)
    }
}

Webster.main()
