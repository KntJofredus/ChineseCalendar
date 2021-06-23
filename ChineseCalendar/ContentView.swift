//
//  ContentView.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    // colorScheme == .dark
    
    @ObservedObject var li: LiJianZuo
    
    @State var titleFrame: CGRect = CGRect()
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGray6)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            
            YueLiSanTu(li: li)
                .environment(\.layoutDirection, .rightToLeft)
                .background(Rectangle().colorInvert())
        }
    }
}

struct YueNianFeng: View {
    var body: some View {
        VStack {
            Text(String(nianFeng.reversed())).font(.caption)
            Text(String(dangYue_JiNian.reversed()))
        }
        .padding(.bottom)
    }
    
    var nianFeng: String
    var dangYue_JiNian: String
    var zhengTong_JiNian: Array<String> = []
    var bieChao_JiNian: Array<String> = []
}

struct YueLiSanTu: View {
    @ObservedObject var li: LiJianZuo
    @State var pianLiang = CGSize.zero
    @State var yueBiaoQian = false
    @State private var dangYeQ = 1
    
    let minDragTranslationForSwipe: CGFloat = 50

    var body: some View {
        ZStack {
            TabView(selection: $dangYeQ) { ForEach(0 ..< 3) { yeQ in
                VStack(alignment: .center, spacing: nil) {
                    YueNianFeng(nianFeng: li.nianSanYe[li.yueSanYe[yeQ].nianQ].nianFen,
                                dangYue_JiNian: li.yueSanYe[yeQ].dangYue_JiNian)
                        .frame(maxWidth: .infinity)
                        .background(Color(UIColor.systemGray6))
                    
                    YueLiXiaoTu(li: li, yeQ: yeQ, xingZhouShu: (li.yueSanYe[yeQ].liuXingZhouF ? 6 : 5))
                        .tabItem {
                            Text(String(yeQ))
                        }
                        .tag(yeQ)
                        .padding()
                        .onDisappear(perform: {
                            if dangYeQ < 1 {
                                li.backwardMonth()
                            }
                            else if dangYeQ > 1 {
                                li.forwartMonth()
                            }
                            self.dangYeQ = 1
                        })
                }
            } }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            VStack(alignment: .center, spacing: nil) {
                YueNianFeng(nianFeng: li.nianFeng,
                            dangYue_JiNian: li.dangYue.dangYue_JiNian,
                            zhengTong_JiNian: li.zhengTong_JiNian)
                    .hidden()
                
                GeometryReader { geo in
                HStack { ForEach(0..<6) { hangOrdx in
                    VStack { ForEach(-1..<8) { hangIdx in
                        if hangOrdx == 0 && hangIdx > 0{
                            QiZhengDian(zi: YueLiSanTu.qiZheng[ hangIdx - 1 ])
                        }
                        else {
                            Circle().hidden()
                        }
                    } }
                } }
                .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
                }
                .padding()
            }
            
        }
    }
    
    
    
    static let xingZhou = ["一", "二", "三", "四", "五", "六"]
    static let qiZheng = ["日", "月", "水", "火", "木", "金", "土"]
}

struct YueLiXiaoTu: View {
    @ObservedObject var li: LiJianZuo
    
    @State var yueBiaoF = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .center) {
                Rectangle().colorInvert()
                
                HStack {
                    ForEach(0..<6) { hangOrdx in
                        if hangOrdx < xingZhouShu {
                            XingZhouHang(li: li, yeQ: yeQ, hangOrdx: hangOrdx)
                                .frame(width: geo.frame(in: .global).width / 6.5 )
                        }
                        if hangOrdx < xingZhouShu-1 {
                            Spacer()
                        }
                    }
                }
                .position(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY)
            }
        }
        
    }
    
    var yeQ: Int
    var xingZhouShu: Int = 5
}

struct XingZhouHang: View {
    @ObservedObject var li: LiJianZuo
    
    var body: some View {
        VStack { ForEach(-1..<8) { hangIdx in
            if hangOrdx == 0 && hangIdx == -1 {
                YueDian(yueFeng: li.yue_Ji[yeQ].yueFen)
            }
            else if hangIdx == 0 {
                XingZhouDian(zi: li.yue_Ji[yeQ].xingZhou_Ji[hangOrdx] )//.hidden()
            }
            else if hangIdx > 0 {
                ZStack {
                    RiDian(ri: li.yue_Ji[yeQ].riYuan_Ji[ hangOrdx*7+hangIdx-1 ])
                        .onTapGesture(count:1, perform: {
                            li.chooseDay(hangOrdx*7+hangIdx-1)
                        })
                    //                            if yue.shuoRi_QiZheng == hangOrdx*7+hangIdx && yueBiaoF {
                    //                                YueBiao(yueFeng: li.yue_Ji[yeQ].yueFen)
                    //                            }
                }
            }
            else {
                Circle().hidden()
            }
        } }
    }
    
    var yeQ: Int
    var hangOrdx: Int
}

struct YueDian: View {
    var body: some View {
        ZStack {
            Circle().foregroundColor(CalendarRed.scheme(.nippon))
            ShuPaiZi(wenZi: yueFeng, ziHao: .caption)
        }
    }
    
    var yueFeng: String
}

struct YueBiao: View {
    var body: some View {
        GeometryReader { g in
            ShuPaiZi(wenZi: yueFeng, ziHao: .caption)
                .padding(2)
                .background(RoundedRectangle(cornerRadius: 2.5)
                                .foregroundColor(CalendarRed.scheme(.nippon)))
                .position(x: 0, y: g.size.height/2 - g.size.width/2)
//                .position(x: g.size.width/2, y: g.size.height/2 - g.size.width * 0.75)
                
        }
    }
    
    var yueFeng: String
}

struct QiZhengDian: View {
    var body: some View {
        GeometryReader { g in
            Circle().hidden()
                .background( ZStack {
                    RoundedRectangle(cornerRadius: 2.5)
                        .frame(width: g.size.width*0.333, height: g.size.width*0.333, alignment: .topLeading)
                        .position(x: 0, y: 0)
                        
                    Text(zi)
                        .font(.caption)
                        .colorInvert()
                        .position(x: 0, y: 0)
                } )
        }
    }
    
    var zi: String
}


struct XingZhouDian: View {
    var body: some View {
        ZStack{
            Circle()
            ShuPaiZi(wenZi: zi, ziHao: .caption2)
                .colorInvert()
        }
    }
    
    
    var zi: String
}

struct RiDian: View {
    var body: some View {
        if ri != nil {
            ZStack{
                if ri!.isToday {
                    Circle().foregroundColor(CalendarRed.scheme(.Soviet))
                    HuoZi(zhuZi: Array(ri!.riMing), fuZi: ri!.jieRi).foregroundColor(.white)
                }
                else if ri!.isChoosen {
                    Circle().stroke()
                        .foregroundColor(CalendarRed.scheme(.China))
                        .background(Circle())
                    HuoZi(zhuZi: Array(ri!.riMing), fuZi: ri!.jieRi).colorInvert()
                }
                else {
                    Circle().stroke()
                    HuoZi(zhuZi: Array(ri!.riMing), fuZi: ri!.jieRi)
                }
            }
        }
        else {
            Circle().foregroundColor(Color(UIColor.systemFill))
        }
    }
    
    var ri: RiYuan?
}

struct ShuPaiZi: View {
    var body: some View {
        VStack(spacing: -1) {
            ForEach( 0 ..< 100) { xu in
                if xu < wenZi_Ji.count {
                    if ziHao != nil {
                        Text(String(wenZi_Ji[xu])).font(ziHao)
                    }
                    else {
                        Text(String(wenZi_Ji[xu]))
                    }
                }
            }
        }
    }
    
    init(wenZi: String, ziHao: Font?) {
        self.wenZi_Ji = Array(wenZi)
        self.ziHao = ziHao
    }
    
    init(wenZi_Ji: Array<Character>, ziHao: Font?) {
        self.wenZi_Ji = wenZi_Ji
        self.ziHao = ziHao
    }
    
    var wenZi_Ji: Array<Character>
    var ziHao: Font?
}

struct HuoZi: View {
    var body: some View {
        GeometryReader { g in
            HStack(spacing: spacing) {
                VStack {
                    ForEach(0 ..< 100) { j in
                        if j < zhuZi.count {
                            Text(String(zhuZi[j]))
                                .font(.system(size:(g.size.width < g.size.height ? g.size.width * 0.2 : g.size.height * 0.2)))
                                .fontWeight(.bold)
                        }
                    }
                }
                
                HStack(alignment: .top, spacing: 0) {
                    ForEach(0 ..< 100) { i in
                        if i < (fuZi.count+1)/2 {
                            VStack(spacing: 1) {
                                ShuPaiZi(wenZi_Ji: fuZi[2*i], ziHao: .system(size:(g.size.width < g.size.height ? g.size.width * 0.15 : g.size.height * 0.15)))
                                if 2*i+1 < fuZi.count {
                                    ShuPaiZi(wenZi_Ji: fuZi[2*i+1], ziHao: .system(size:(g.size.width < g.size.height ? g.size.width * 0.15 : g.size.height * 0.15)))
                                }
                            }
                        }
                    }
                }
            }
            .position(x: g.size.width/2, y: g.size.height/2)
        }
    }

    var spacing: CGFloat = 2
    var zhuZi: [Character] = []
    var fuZi: [[Character]] = []
}

enum RedType {
    case China
    case cina
    case mix
    case Soviet
    case nippon
}

struct CalendarRed {
    static func scheme(_ of: RedType) -> Color {
        switch of {
        case .China   : return Color(red: 238/256.0, green: 28/256.0, blue: 37/256.0)
        case .cina    : return Color(red: 222/256.0, green: 41/256.0, blue: 16/256.0)
        case .mix     : return Color(red: 191/256.0, green:  0/256.0, blue:  8/256.0)
        case .Soviet  : return Color(red: 205/256.0, green:  0/256.0, blue:  0/256.0)
        case .nippon  : return Color(red: 176/256.0, green:  0/256.0, blue: 15/256.0)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(li: LiJianZuo())
            .preferredColorScheme(.dark)
        
//        ContentView(calendar: LiJianZuo(date: {
//            let formatter = DateFormatter()
//            formatter.locale = Locale(identifier: "en_US_POSIX")
//            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
//            return formatter.date(from:"1900-01-01T00:00:00+0800")!}() ))
//            .preferredColorScheme(.dark)
            
    }
}
