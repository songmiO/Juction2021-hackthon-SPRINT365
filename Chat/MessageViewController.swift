//
//  MessgeViewController.swift
//  TRIDZ
//
//  Created by sangheon on 2021/05/21.
//


import UIKit
import Prestyler
import SocketIO

//protocol PoketmonProtocol {
//    func showPopup(poketmon:chatType)
//}

class MessageViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextViewDelegate {
    
    var dict:[String:String] = [:]
    var myWords = [String]()
    var myMessage = [String]()
//    var delegate:PoketmonProtocol?
    let manager = SocketManager(socketURL: URL(string: "https://print-test2.azurewebsites.net")!, config: [.log(true), .compress])
    var socket:SocketIOClient!
    
    
    @IBOutlet weak var PersonName: UILabel!
    @IBOutlet weak var PersonJob: UILabel!
    @IBOutlet weak var decoView:UIView! {
        didSet {
            decoView.clipsToBounds = true
            decoView.layer.cornerRadius = 20
            decoView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        }
    }
    
    @IBOutlet weak var TopView: UIView! {
        didSet {
            TopView.clipsToBounds = true
            TopView.layer.cornerRadius = 20
            TopView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBOutlet weak var chatTableView: UITableView! {
        didSet {
            self.chatTableView.delegate = self
            self.chatTableView.dataSource = self
            chatTableView.separatorStyle = .none //구분선 사용 x
        }
    }
    @IBOutlet weak var inputHeight: NSLayoutConstraint!
    
    @IBOutlet weak var inputTextView: UITextView! {
        didSet {
            self.inputTextView.delegate = self
            self.inputTextView.layer.cornerRadius = 14
            var borderColor : UIColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0)
            self.inputTextView.layer.borderWidth = 0.5
            self.inputTextView.layer.borderColor = borderColor.cgColor
            self.inputTextView.layer.cornerRadius = 5.0
        }
    }
    
    @IBOutlet weak var inputViewBottomMargin: NSLayoutConstraint!
    
    var chatDatas = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        socket = manager.defaultSocket
        addHandlers()
        socket.connect()
        
        //사용하려는 셀을 등록해야 사용가능
        chatTableView.register(UINib(nibName: "MyCell", bundle: nil), forCellReuseIdentifier: "myCell")
        chatTableView.register(UINib(nibName: "YourCell", bundle: nil), forCellReuseIdentifier: "yourCell")
        //xib파일 연결
        
        //키보드 관련 옵저버 -상태틀 알려 주는거
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(noti:Notification) {
        let notiInfo = noti.userInfo //userInfo를 통해 정보를 받아옴
        let keyboardFrame = notiInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let height = keyboardFrame.size.height - self.view.safeAreaInsets.bottom // safearea 뺴줘야함
    
        let animationDuration = notiInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: animationDuration) {
            self.inputViewBottomMargin.constant = height
            self.view.layoutIfNeeded()
        }
        
    }
    
    @objc func keyboardWillHide(noti:Notification) {
        let notiInfo = noti.userInfo
        let animationDuration = notiInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: animationDuration + 1) {
            
            self.inputViewBottomMargin.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    //MARK: TABELVIEW@@@@
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //걍 번갈아 가면서
        
        if indexPath.row % 2 == 0 {
            let myCell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! MyCell
            myCell.myTextView.text = chatDatas[indexPath.row]
            
            let opt = myWords.first ?? "DB"
            highlight(highView:myCell.myTextView, message: myCell.myTextView.text, worldValue: opt)
            DispatchQueue.global().sync {
                for i in myWords {
                    highlight(highView:myCell.myTextView, message: myCell.myTextView.text, worldValue: i)
                }
            }
                let a = myCell.myTextView.text
                var result = a!.components(separatedBy: " ")
                print(result)
                print("확인")
            
            
            myCell.yourobj =  {
                
                for i in self.myWords {
                    self.detectWords(str: i,textChcunk: result)
                    
                }
                self.gopop()
            }
            
            
            myCell.selectionStyle = .none //클릭 이벤트 없애기
            return myCell
            
        } else {
            let yourCell = tableView.dequeueReusableCell(withIdentifier: "yourCell", for: indexPath) as! YourCell
            yourCell.yourCellTextView.text = chatDatas[indexPath.row]
            DispatchQueue.global().sync {
                for j in self.myWords {
                    self.highlight(highView: yourCell.yourCellTextView, message: yourCell.yourCellTextView.text, worldValue: j)
                }
            }
           
            let b = yourCell.yourCellTextView.text
            var result2 = b!.components(separatedBy: " ")
            yourCell.yourobj = {
                for i in self.myWords {
                    self.detectWords(str: i,textChcunk: result2 )
                }
                self.gopop()
            }
            
            yourCell.selectionStyle = .none
           
            return yourCell
        }
       
    }
     
    
    
    @IBAction func sendData(_ sender: Any) {
       // inputTextView.text -> =chatDatas
        self.socket.emit("new message", ["message": self.inputTextView.text])
        
        chatDatas.append(inputTextView.text)
        inputTextView.text.removeAll() //입력하고 난뒤 텍스트필드 비워주기
        
        //chatTableView.reloadData()
        let lastIndexPath = IndexPath(row: chatDatas.count - 1 , section: 0)
        //해당하는 로우만 갱신
        chatTableView.insertRows(at: [lastIndexPath], with: UITableView.RowAnimation.automatic)
        
        //테이블뷰 대화에 따라 올려주기
        //3개 데이터가 있는 array일 경우
        // array.count = 3
        // array.row =>2  0부터 시작하니깐
        inputHeight.constant = 40
        chatTableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.contentSize.height <= 40 {
            inputHeight.constant = 40
        } else if textView.contentSize.height >= 100{
            inputHeight.constant = 100
        } else {
            inputHeight.constant = textView.contentSize.height //안에있는 컨텐츠에 맞춰서 인풋크기 조절
            
        }
    }
    
    
    
    //MARK: - CORE LOGIC FUCN
    //하이라이트주기
    func highlight(highView: UITextView,message:String,worldValue:String) {
        Prestyler.defineRule("T", UIColor.systemBlue,Prestyle.underline)
        let att = message.prefilter(text: worldValue, by: "T")
        highView.attributedText = att.prestyled()
    }
    
 
    func detectWords(str:String,textChcunk:[String]) {
        print("check")
        guard let rvc = self.storyboard?.instantiateViewController(identifier: "pop") as? PopupViewController else {
                    return
                }
        for i in textChcunk {
          if i == str {
            let ud = UserDefaults.standard
            ud.setValue(i, forKey: "wordName")
            ud.setValue(dict[i]!, forKey: "disc")
            print(i)
            print(dict[i]!)
            print("우어낫어론")
           }
        }
    }
    
    func gopop() {
        guard let rvc = self.storyboard?.instantiateViewController(identifier: "pop") as? PopupViewController else {
                    return
                }
        //rvc.Data = myChatData[0]
        present(rvc, animated: true, completion: nil)
    }
    
    
    //MARK: SERVER Soceket
  
    
    func addHandlers() {
           socket.on("connect") {data, ack in
               print("socket connected")
               print("Type \"quit\" to stop")
//               self.socket.emit("add user", ["username": "charles"])
           }
           socket.on("login") {data, ack in
               print(data)
            print("@@@@@@@@@@@@@@")
           }
           socket.on("new message") { dataArray,Ack in
            var chat = chatType()
           
            let data = dataArray[0] as! NSDictionary
            let test = data["descriptions"] as! NSDictionary
            self.dict = test as! [String : String]
            print(self.dict)
            print("~~~~~~~~~~~~~~~~~~~~~~~~~~")
            for i in test.allKeys {
                self.myWords.append(i as! String)
            }
            for j in test.allValues {
                self.myMessage.append(j as! String)
            }
            
            print(self.myWords)
            print(self.myMessage)
            print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
        }
       }
    
    @IBAction func goBack(_sender:Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //Show
//    func showPopup(poketmon:chatType) {
//        self.view.addSubview(infoView)
//        infoView.translatesAutoresizingMaskIntoConstraints = false
//        infoView.centerXAnchor.constraint(equalTo:self.view.centerXAnchor).isActive = true
//        infoView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor,constant: -55).isActive = true
//        infoView.heightAnchor.constraint(equalToConstant: 300).isActive = true
//        infoView.widthAnchor.constraint(equalToConstant: view.frame.width - 200).isActive = true
//        infoView.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
//        infoView.alpha = 0
//
////        infoView.poketmon = poketmon
//
//        UIView.animate(withDuration: 0.3, animations: {
//            //self.blurEffectView.alpha = 1
//           // self.infoView.transform = .identity
//            self.infoView.alpha = 1
//        })
//    }
//
}
