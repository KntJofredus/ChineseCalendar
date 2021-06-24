//
//  ChineseCalendarKernel.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/9.
//

import Foundation

struct LI {
    var jinRiQi: Date // 今日期
    
    var jinNianX: Int // 今年序
    var jinYueX: Int // 今月序
    var jinYue_RunF: Bool // 今閏月否
    var jinRiX: Int // 今日序
    
    var dangNianX: Int // 當年序
    var dangYueX: Int // 當月序
    var dangYue_RunF: Bool // 當閏月否
    var dangRiX: Int // 當日序
    
    var dangNian: Nian // 當年
    var dangYue: Yue // 當月
    var dangRi: Ri // 當日
    
    var quNian: Nian // 去年
    var ciNian: Nian // 次年
    
    var shangYue: Yue // 上月
    var ciYue: Yue // 次月
    
    var jinRi_YueQ: Int
    var jinRi_RiQ: Int
    
    var dangRi_YueQ: Int
    var dangRi_RiQ: Int
    
//    var shangYue: Yue // 上月
//    var ciYue: Yue // 次月
    
    var nianSanYe: Array<NianYuan> = []
    var yueSanYe: Array<YueYuan> = []
    
    init(_ date: Date = Date()) {
        jinRiQi = Calendar.current.startOfDay(for: date)
        
        jinNianX = LI.kongLi.component(.year, from: Nian.YuanRi(date: jinRiQi))
        jinYueX = LI.ziJinLi.component(.month, from: jinRiQi)
        jinYue_RunF = LI.deRunYueFou(riQi: date)
        jinRiX = LI.ziJinLi.component(.day, from: jinRiQi)
        
        dangNianX = jinNianX
        dangYueX = jinYueX
        dangYue_RunF = jinYue_RunF
        dangRiX = jinRiX
        
        dangNian = Nian(nianX: dangNianX)
        dangYue = Yue(nian: dangNian, yueX: dangYueX, runYueF: dangYue_RunF)
        dangRi = Ri(yue: dangYue, riX: dangRiX)
        
        quNian = Nian(nianX: dangNianX-1)
        ciNian = Nian(nianX: dangNianX+1)
        
        var (shangYue_Nian, shangYue_YueX, shangYue_RunF): (Nian, Int, Bool)
        if dangYue_RunF {
            (shangYue_Nian, shangYue_YueX, shangYue_RunF) = (dangNian, dangYueX, false)
        }
        else {
            (shangYue_Nian, shangYue_YueX) = (dangYueX == 1) ? (quNian, 12) : (dangNian, dangYueX - 1)
            shangYue_RunF = shangYue_Nian.runYueX == shangYue_YueX
        }
        shangYue = Yue(nian: shangYue_Nian, yueX: shangYue_YueX, runYueF: shangYue_RunF)
        shangYue.nianQian = (shangYue_Nian.nianX == dangNianX) ? 1 : 0
        
        var (ciYue_Nian, ciYue_YueX, ciYue_RunF) = (dangNian, dangYueX, dangYue_RunF)
        if dangYue_RunF {
            ciYue_YueX = dangYueX + 1
            ciYue_RunF = false
        }
        else if dangNian.runYueX == dangYueX {
            ciYue_RunF = true
        }
        else {
            ciYue_YueX = dangYueX + 1
            ciYue_RunF = false
        }
        if ciYue_YueX == 13 {
            ciYue_Nian = ciNian
            ciYue_YueX = 1
        }
        ciYue = Yue(nian: ciYue_Nian, yueX: ciYue_YueX, runYueF: ciYue_RunF)
        ciYue.nianQian = (ciYue_Nian.nianX == dangNianX) ? 1 : 2
            
        nianSanYe = [
            quNian.deNianYuan(),
            dangNian.deNianYuan(),
            ciNian.deNianYuan()
        ]
        
        yueSanYe = [
            shangYue.deYueYuan(),
            dangYue.deYueYuan(),
            ciYue.deYueYuan()
        ]
        
        jinRi_YueQ = 1
        jinRi_RiQ = dangRiX - 1 + dangYue.shuoRi_QiZheng - 1
        dangRi_YueQ = jinRi_YueQ
        dangRi_RiQ = jinRi_RiQ
        
        yueSanYe[jinRi_YueQ].riYuan_Ji[jinRi_RiQ]!.isToday = true
        yueSanYe[dangRi_YueQ].riYuan_Ji[dangRi_RiQ]!.isChoosen = true
    }
    
    mutating func zeRi(_ xinDangRi_RiQ: Int) {
        let xinDangRiQ = xinDangRi_RiQ - yueSanYe[1].shuoRi_QiZheng + 1
        if xinDangRiQ < 0 || xinDangRiQ >= yueSanYe[1].riShu {
            return
        }
        if dangRi_YueQ >= 0 && dangRi_YueQ < 3 {
            yueSanYe[dangRi_YueQ].riYuan_Ji[dangRi_RiQ]!.isChoosen = false
        }
        dangRi_YueQ = 1
        dangRi_RiQ = xinDangRi_RiQ
        yueSanYe[dangRi_YueQ].riYuan_Ji[dangRi_RiQ]!.isChoosen = true
        dangRiX = xinDangRiQ
        dangRi = Ri(yue: dangYue, riX: dangRiX)
    }
    
    mutating func zeYue(_ direction: ZeYue_FangXiang) {
        switch direction {
        case .ShangYue:
            zhiShangYue()
        case .CiYue:
            zhiCiYue()
        }
    }
    
    mutating func zhiShangYue() {
        var xinLi = self
        
        let shangYue_Nian = (shangYue.nianQian == 1) ? dangNian : quNian
        let (shangYue_YueX, shangYue_RunF) = (shangYue.yueX, shangYue.runF)
        var (qianYue_Nian, qianYue_YueX, qianYue_RunF): (Nian, Int, Bool)
        if shangYue_RunF {
            (qianYue_Nian, qianYue_YueX, qianYue_RunF) = (shangYue_Nian, shangYue_YueX, false)
        }
        else {
            (qianYue_Nian, qianYue_YueX) = (shangYue_YueX == 1) ? (quNian, 12) : (shangYue_Nian, shangYue_YueX - 1)
            qianYue_RunF = qianYue_Nian.runYueX == qianYue_YueX
        }
        var qianYue = Yue(nian: qianYue_Nian, yueX: qianYue_YueX, runYueF: qianYue_RunF)
         // 先於年三葉更新
        
        switch shangYue.nianQian {
        case 0:
            let qianNian = Nian(nianX: dangNianX-2)
            
            xinLi.dangNianX = quNian.nianX
            xinLi.dangNian = quNian
            
            xinLi.quNian = qianNian
            xinLi.ciNian = dangNian
            
            xinLi.nianSanYe = [ qianNian.deNianYuan(), nianSanYe[0], nianSanYe[1] ]
        case 1:
//                xinLi.dangNianX = dangNianX
//                xinLi.dangNian = dangNian
//                xinLi.quNian = quNian
//                xinLi.ciNian = ciNian
//                xinLi.nianSanYe = [ qianNian.deNianYuan(), nianSanYe[0], nianSanYe[1] ]
            break
        default:
            exit(-1)
        }
        
        xinLi.dangYueX = shangYue.yueX
        xinLi.dangYue_RunF = shangYue.runF
        xinLi.dangYue = shangYue
        
        xinLi.dangRiX = 1
        xinLi.dangRi = Ri(nian: xinLi.dangNian, yue: xinLi.dangYue, riX: 1)
        
        xinLi.shangYue = qianYue
        xinLi.ciYue = dangYue
        
        xinLi.shangYue.nianQian = (qianYue_Nian.nianX == shangYue_Nian.nianX) ? 1 : 0
        xinLi.dangYue.nianQian = 1
        xinLi.ciYue.nianQian = (dangNianX == shangYue_Nian.nianX) ? 1 : 2
        
        xinLi.jinRi_YueQ += 1
        xinLi.dangRi_YueQ = 1
        if xinLi.jinRi_YueQ != 1 {
            xinLi.dangRi_RiQ = shangYue.shuoRi_QiZheng - 1
        }
        else {
            xinLi.dangRi_RiQ = jinRi_RiQ
        }
        
        xinLi.yueSanYe = [ qianYue.deYueYuan(), yueSanYe[0], yueSanYe[1] ]
        (xinLi.yueSanYe[0].nianQ, xinLi.yueSanYe[1].nianQ, xinLi.yueSanYe[2].nianQ) = (xinLi.shangYue.nianQian, xinLi.dangYue.nianQian, xinLi.ciYue.nianQian)
        
        xinLi.yueSanYe[2].riYuan_Ji[dangRi_RiQ]!.isChoosen = false
        xinLi.yueSanYe[1].riYuan_Ji[xinLi.dangRi_RiQ]!.isChoosen = true
        if xinLi.jinRi_YueQ >= 0 && xinLi.jinRi_YueQ <= 2 {
            xinLi.yueSanYe[xinLi.jinRi_YueQ].riYuan_Ji[jinRi_RiQ]!.isToday = true
        }
            
        self = xinLi
    }
    
    mutating func zhiCiYue() {
        var xinLi = self
        
        let ciYue_Nian = (ciYue.nianQian == 1) ? dangNian : ciNian
        let (ciYue_YueX, ciYue_RunF) = (ciYue.yueX, ciYue.runF)
        var (houYue_Nian, houYue_YueX, houYue_RunF) = (ciYue_Nian, ciYue_YueX, ciYue_RunF)
        if ciYue_RunF {
            houYue_YueX = ciYue_YueX + 1
            houYue_RunF = false
        }
        else if ciYue_Nian.runYueX == ciYue_YueX {
            houYue_RunF = true
        }
        else {
            houYue_YueX = ciYue_YueX + 1
            houYue_RunF = false
        }
        if houYue_YueX == 13 {
            houYue_Nian = ciNian
            houYue_YueX = 1
        }
        var houYue = Yue(nian: houYue_Nian, yueX: houYue_YueX, runYueF: houYue_RunF)
        houYue.nianQian = (houYue_Nian.nianX == ciYue_Nian.nianX) ? 1 : 2 // 先於年三葉更新
        
        switch ciYue.nianQian {
        case 2:
            let houNian = Nian(nianX: dangNianX+2)
            
            xinLi.dangNianX = ciNian.nianX
            xinLi.dangNian = ciNian
            
            xinLi.quNian = dangNian
            xinLi.ciNian = houNian
            
            xinLi.nianSanYe = [ nianSanYe[1], nianSanYe[2], houNian.deNianYuan() ]
        case 1:
//                xinLi.dangNianX = dangNianX
//                xinLi.dangNian = dangNian
//                xinLi.quNian = quNian
//                xinLi.ciNian = ciNian
//                xinLi.nianSanYe = [ qianNian.deNianYuan(), nianSanYe[0], nianSanYe[1] ]
            break
        default:
            exit(-1)
        }
        
        xinLi.dangYueX = ciYue.yueX
        xinLi.dangYue_RunF = ciYue.runF
        xinLi.dangYue = ciYue
        xinLi.dangRiX = 1
        xinLi.dangRi = Ri(nian: xinLi.dangNian, yue: xinLi.dangYue, riX: 1)
        
        xinLi.shangYue = dangYue
        xinLi.ciYue = houYue
        
        xinLi.shangYue.nianQian = (dangNianX == ciYue_Nian.nianX) ? 1 : 0
        xinLi.dangYue.nianQian = 1
        xinLi.ciYue.nianQian = (houYue_Nian.nianX == ciYue_Nian.nianX) ? 1 : 2
        
        xinLi.jinRi_YueQ -= 1
        xinLi.dangRi_YueQ = 1
        if xinLi.jinRi_YueQ != 1 {
            xinLi.dangRi_RiQ = ciYue.shuoRi_QiZheng - 1
        }
        else {
            xinLi.dangRi_RiQ = jinRi_RiQ
        }
        
        xinLi.yueSanYe = [ yueSanYe[1], yueSanYe[2], houYue.deYueYuan() ]
        (xinLi.yueSanYe[0].nianQ, xinLi.yueSanYe[1].nianQ, xinLi.yueSanYe[2].nianQ) = (xinLi.shangYue.nianQian, xinLi.dangYue.nianQian, xinLi.ciYue.nianQian)
        
        xinLi.yueSanYe[0].riYuan_Ji[dangRi_RiQ]!.isChoosen = false
        xinLi.yueSanYe[1].riYuan_Ji[xinLi.dangRi_RiQ]!.isChoosen = true
        if xinLi.jinRi_YueQ >= 0 && xinLi.jinRi_YueQ <= 2 {
            xinLi.yueSanYe[xinLi.jinRi_YueQ].riYuan_Ji[jinRi_RiQ]!.isToday = true
        }
        
        self = xinLi
    }
    
    mutating func zeNian(_ fangXiang: ZeNian_FangXiang) {
        var xinLi = self
        
        switch fangXiang {
        case .QuNian:
            xinLi.dangNianX -= 1
            xinLi.dangNian = quNian
        case .CiNian:
            xinLi.dangNianX += 1
            xinLi.dangNian = ciNian
        }
        if dangYue_RunF && xinLi.dangNian.runYueX != dangYueX {
            xinLi.dangYue_RunF = false
        }
        xinLi.dangYue = Yue(nian: xinLi.dangNian, yueX: xinLi.dangYueX, runYueF: xinLi.dangYue_RunF)
        xinLi.dangRiX = 1
        xinLi.dangRi = Ri(yue: xinLi.dangYue, riX: xinLi.dangRiX)
        
        switch fangXiang {
        case .QuNian:
            xinLi.quNian = Nian(nianX: xinLi.dangNianX-1)
            xinLi.ciNian = dangNian
        case .CiNian:
            xinLi.quNian = dangNian
            xinLi.ciNian = Nian(nianX: xinLi.dangNianX+1)
        }
        
        xinLi.nianSanYe = [
            xinLi.quNian.deNianYuan(),
            xinLi.dangNian.deNianYuan(),
            xinLi.ciNian.deNianYuan()
        ]
        
        var (shangYue_Nian, shangYue_YueX, shangYue_RunF): (Nian, Int, Bool)
        if xinLi.dangYue_RunF {
            (shangYue_Nian, shangYue_YueX, shangYue_RunF) = (xinLi.dangNian, xinLi.dangYueX, false)
        }
        else {
            (shangYue_Nian, shangYue_YueX) = (xinLi.dangYueX == 1) ? (xinLi.quNian, 12) : (xinLi.dangNian, xinLi.dangYueX - 1)
            shangYue_RunF = shangYue_Nian.runYueX == shangYue_YueX
        }
        xinLi.shangYue = Yue(nian: shangYue_Nian, yueX: shangYue_YueX, runYueF: shangYue_RunF)
        xinLi.shangYue.nianQian = (shangYue_Nian.nianX == xinLi.dangNianX) ? 1 : 0
        
        var (ciYue_Nian, ciYue_YueX, ciYue_RunF) = (xinLi.dangNian, xinLi.dangYueX, xinLi.dangYue_RunF)
        if xinLi.dangYue_RunF {
            ciYue_YueX = xinLi.dangYueX + 1
            ciYue_RunF = false
        }
        else if xinLi.dangNian.runYueX == xinLi.dangYueX {
            ciYue_RunF = true
        }
        else {
            ciYue_YueX = xinLi.dangYueX + 1
            ciYue_RunF = false
        }
        if ciYue_YueX == 13 {
            ciYue_Nian = xinLi.ciNian
            ciYue_YueX = 1
        }
        xinLi.ciYue = Yue(nian: ciYue_Nian, yueX: ciYue_YueX, runYueF: ciYue_RunF)
        xinLi.ciYue.nianQian = (ciYue_Nian.nianX == xinLi.dangNianX) ? 1 : 2
        
        xinLi.yueSanYe = [
            xinLi.shangYue.deYueYuan(),
            xinLi.dangYue.deYueYuan(),
            xinLi.ciYue.deYueYuan()
        ]
        
        switch fangXiang {
        case .QuNian:
            xinLi.jinRi_YueQ += LI.ziJinLi.dateComponents([.month], from: xinLi.dangYue.shuoRiQi, to: dangYue.shuoRiQi).month!
        case .CiNian:
            xinLi.jinRi_YueQ -= LI.ziJinLi.dateComponents([.month], from: dangYue.shuoRiQi, to: xinLi.dangYue.shuoRiQi).month!
        }
        xinLi.dangRi_YueQ = 1
        if xinLi.jinRi_YueQ != 1 {
            xinLi.dangRi_RiQ = xinLi.dangYue.shuoRi_QiZheng - 1
        }
        else {
            xinLi.dangRi_RiQ = xinLi.jinRi_RiQ
        }
        
        if xinLi.jinRi_YueQ >= 0 && xinLi.jinRi_YueQ <= 2 {
            xinLi.yueSanYe[xinLi.jinRi_YueQ].riYuan_Ji[xinLi.jinRi_RiQ]!.isToday = true
        }
        xinLi.yueSanYe[xinLi.dangRi_YueQ].riYuan_Ji[xinLi.dangRi_RiQ]!.isChoosen = true
        
        self = xinLi
    }
    
    enum ZeNian_FangXiang {
        case QuNian
        case CiNian
    }
    
    enum ZeYue_FangXiang {
        case ShangYue
        case CiYue
    }
    
    static func deRunYueFou(riQi: Date) -> Bool {
        let yueX = LI.ziJinLi.component(.month, from: riQi)
        let qianYueX = LI.ziJinLi.component(.month, from: Nian.QianHuiRi(date: riQi))
        return qianYueX == yueX
   }
   
    
    static let ziJinLi: Calendar = Calendar(identifier: .chinese)
    static let kongLi: Calendar = Calendar(identifier: .iso8601)
}

struct RiYuan: Identifiable {
    var id: Int
    
    var riMing: String
    var ganZhi: String
    var jieRi: Array<Array<Character>> = []
    
    var isToday: Bool = false
    var isChoosen: Bool = false
}

extension RiYuan {
    init(ri: Ri) {
        id = ri.hashValue
        
        riMing = Cina.RiName[ri.riX - 1]
        ganZhi = GanZhi.convert(ri.ganZhiX)
        jieRi = ri.jieLing.map { Array($0) }
    }
}

struct Ri : Hashable {
    var riX: Int
    var ganZhiX: Int
    
    var qiZhengX: Int
    var xingZhouX: Int
    
    var jieLing: Array<String> = []
    
    var riQian: Int
    var yueQian: Int
    
    func deRiYuan() -> RiYuan {
        return RiYuan(id: riX,
                      riMing: Cina.RiName[riX-1],
                      ganZhi: GanZhi.convert(ganZhiX),
                      jieRi: jieLing.map { Array($0) },
                      isToday: false,
                      isChoosen: false)
    }
}

extension Ri {
    init(nian: Nian? = nil, yue: Yue, riQi: Date) {
        riX = LI.ziJinLi.component(.day, from: riQi)
        
        ganZhiX = Integer.mod(b: (yue.shuoRi_GanZhi + riX - 1), n: 60) + 1
        qiZhengX = LI.ziJinLi.component(.weekday, from: riQi)
        xingZhouX = LI.ziJinLi.component(.weekOfMonth, from: riQi)
        
        jieLing = []
        if let riJieLing = yue.jieLing[riX] {
            for jie in riJieLing.split(separator: " ") {
                jieLing.append(String(jie))
            }
        }
        
        riQian = riX - 1 + yue.shuoRi_QiZheng - 1
        yueQian = yue.yueQian
        
    }
    
    init(nian: Nian? = nil, yue: Yue, riX: Int) {
        self.riX = riX
        
        ganZhiX = Integer.mod(b: (yue.shuoRi_GanZhi-1 + riX - 1), n: 60) + 1
        
        qiZhengX = Integer.mod(b: (yue.shuoRi_QiZheng-1 + riX - 1), n: 7) + 1
        xingZhouX = yue.shuoRi_XingZhou + (yue.shuoRi_QiZheng-1 + riX - 1) / 7
        
        jieLing = []
        if let riJieLing = yue.jieLing[riX] {
            for jie in riJieLing.split(separator: " ") {
                jieLing.append(String(jie))
            }
        }
        
        riQian = riX - 1 + yue.shuoRi_QiZheng - 1
        yueQian = yue.yueQian
    }
}

struct YueYuan: Identifiable {
    var id: Int
    
    var yueFen: String // 月份
    var ganZhi: String // 干支
    var dangYue_JiNian: String // 當月紀年
    
    var shuoRi_GanZhi: Int // 朔日干支
    var shuoRi_QiZheng: Int // 朔日七政
    var riShu: Int // 日數
    
    var riYuan_Ji: Array<RiYuan?> = [] // 日元集
    var xingZhou_Ji: Array<String> = [] // 星週集
    
    var nianQ: Int // 年签
    
    var liuXingZhouF: Bool = false // 六星週否
}

extension YueYuan {
    init(yue: Yue) {
        id = yue.hashValue
        
        yueFen = Cina.YueName[yue.yueX + (yue.runF ? 12 : 0) - 1]
        ganZhi = GanZhi.convert(tianGan: yue.tianGanX, diZhi: yue.diZhiX)
        
        dangYue_JiNian = yue.nianHaoNianFen
        
        shuoRi_GanZhi = yue.shuoRi_GanZhi
        shuoRi_QiZheng = yue.shuoRi_QiZheng
        
        riShu = yue.riShu
        
        riYuan_Ji = []
        for xu in (0 ..< 7*6 ) {
            let riQ = xu + 1 - shuoRi_QiZheng
            if  (riQ >=  0 && riQ < yue.riShu) {
                riYuan_Ji.append(RiYuan(id: xu,
                                        riMing: Cina.RiName[riQ],
                                        ganZhi: GanZhi.convert(shuoRi_GanZhi+riQ),
                                        jieRi: [Array(GanZhi.convert(shuoRi_GanZhi+riQ))] + yue.jieLing[riQ+1]!.split(separator: " ").map{ Array($0) },
                                        isToday: false,
                                        isChoosen: false))
            }
            else {
                riYuan_Ji.append(nil)
            }
        }
        
        nianQ = yue.nianQian
    }
}

struct Yue : Hashable {
    var yueX: Int
    var runF: Bool
    
    var tianGanX: Int
    var diZhiX: Int
    
    var shuoRiQi: Date
    var shuoRi_GanZhi: Int
    var shuoRi_QiZheng: Int
    var shuoRi_XingZhou: Int
    
    var riShu: Int
    var jieLing: [Int: String] = [:]
    
    var guoHaoX: Int = -1 // 國號序
    var guoHao: String = "明虞" // 國號
    var nianHaoX: Int = -1 // 年號序
    var nianHao: String = "前" // 年號
    var nianHaoNianX: Int = 1 // 年號年序
    var nianHaoNianFen: String = "元年" // 年號年序
    
    var yueQian: Int
    var nianQian: Int = 1
    
    func deYueYuan() -> YueYuan {
        var xingZhou_Ji: Array<String> = []
        for xu in (0 ..< 6) {
            xingZhou_Ji.append(NumConverter.convert(shuoRi_XingZhou+xu)+"週")
        }
        
        var riYuan_Ji: Array<RiYuan?> = []
        for xu in (0 ..< (7*6)) {
            let liRiQ = xu + 1 - shuoRi_QiZheng
            var riLing: Array<Array<Character>> = [Array(GanZhi.convert(shuoRi_GanZhi+liRiQ))]
            if let riJieLing = jieLing[liRiQ+1] {
                for jie in riJieLing.split(separator: " ") {
                    riLing.append(Array(jie))
                }
            }
            if (liRiQ >= 0 && liRiQ < riShu) {
                riYuan_Ji.append(RiYuan(id: xu,
                                        riMing: Cina.RiName[liRiQ],
                                        ganZhi: GanZhi.convert(shuoRi_GanZhi+liRiQ),
                                        jieRi: riLing,
                                        isToday: false,
                                        isChoosen: false) )
            }
            else {
//                if xu == 35 {
//                    break
//                }
                riYuan_Ji.append(nil)
            }
        }
        return YueYuan(id: self.hashValue,
                       yueFen: Cina.YueName[yueX-1+(runF ? 12 : 0)],
                       ganZhi: GanZhi.convert(tianGan: tianGanX, diZhi: diZhiX),
                       dangYue_JiNian: nianHaoNianFen,
                       shuoRi_GanZhi: shuoRi_GanZhi,
                       shuoRi_QiZheng: shuoRi_QiZheng,
                       riShu: riShu,
                       riYuan_Ji: riYuan_Ji,
                       xingZhou_Ji: xingZhou_Ji,
                       nianQ: nianQian,
                       liuXingZhouF: riYuan_Ji[35] != nil)
    }
    
    init(nian: Nian, yueX: Int, runYueF: Bool) {
        self.yueX = yueX
        self.runF = runYueF
        
        (tianGanX, diZhiX) = ((2 + (nian.ganZhiX % 10) % 5 + yueX) % 10 + 1, yueX)
        
        shuoRiQi = LI.ziJinLi.date(byAdding: .month, value: yueX + ((runYueF || yueX > nian.runYueX) ? 1 : 0) - 1, to: nian.yuanRiQi)!
        shuoRi_GanZhi = Yue.deShuoRiGanZhi(shuoRiQi: shuoRiQi)
        shuoRi_QiZheng = Yue.deShuoRiQiZheng(shuoRiQi: shuoRiQi)
        shuoRi_XingZhou = LI.ziJinLi.component(.weekOfYear, from: shuoRiQi)
        
        riShu = (runYueF) ? nian.runYueRiShu[yueX]! : nian.liYueRiShu[yueX-1]
        var xJieLing: [Int: String] = [:]
        if yueX != 12 && !runYueF {
            xJieLing = Cina.YueLingJieRi[yueX-1]
        }
        else if runYueF {
            xJieLing = Cina.YueLingJieRi[yueX-1]
        }
        for (xu, jie) in xJieLing {
            if xu > 0 {
                if let riJieLing = jieLing[xu] {
                    jieLing[xu] = riJieLing + " " + jie
                }
                else {
                    jieLing[xu] = jie
                }
            }
            else {
                let riXu = riShu+xu+1
                if let riJieLing = jieLing[riXu] {
                    jieLing[riXu] = riJieLing + " " + jie
                }
                else {
                    jieLing[riXu] = jie
                }
            }
        }
        
        (guoHaoX, nianHaoX, nianHaoNianX) = nian.zhengTong_JiNianX[nian.yue_JiNianX[yueX + (runYueF ? 12 : 0)]!]
        if guoHaoX == -1 {
            guoHao = Cina.GuoHaoBiao[0].guoHao
        }
        else {
            guoHao = Cina.GuoHaoBiao[guoHaoX].guoHao
        }
        if nianHaoX == -1 {
            nianHao = "前"
        }
        else {
            nianHao = Cina.NianHaoBiao[guoHao]![nianHaoX].nianHao
        }
        nianHaoNianFen = guoHao + nianHao + NumConverter.convert(nianHaoNianX) + "年"
        
        yueQian = yueX - 1
        if (runYueF || yueX > nian.runYueX) {
            yueQian += 1
        }
    }
    
    init(nian: Nian, riQi: Date) {
        yueX = LI.ziJinLi.component(.month, from: riQi)
        runF = Yue.deRunYueFou(nian: nian, yueX: yueX, riQi: riQi)

        (tianGanX, diZhiX) = (2+(nian.ganZhiX%10)%5+1+yueX, yueX)
        
        shuoRiQi = Nian.ShuoRi(date: riQi)
        shuoRi_GanZhi = Yue.deShuoRiGanZhi(shuoRiQi: shuoRiQi)
        shuoRi_QiZheng = Yue.deShuoRiQiZheng(shuoRiQi: shuoRiQi)
        shuoRi_XingZhou = LI.ziJinLi.component(.weekOfYear, from: shuoRiQi)
        
        riShu = (runF) ?  nian.runYueRiShu[yueX]! : nian.liYueRiShu[yueX-1]
        var xJieLing: [Int: String] = [:]
        if yueX != 12 {
            xJieLing = Cina.YueLingJieRi[yueX-1]
        }
        else {
            if yueX == nian.runYueX {
                xJieLing = Cina.YueLingJieRi[yueX-1]
            }
            else if runF {
                xJieLing = Cina.YueLingJieRi[yueX-1]
            }
        }
        for (xu, jie) in xJieLing {
            if xu > 0 {
                if let riJieLing = jieLing[xu] {
                    jieLing[xu] = riJieLing + " " + jie
                }
                else {
                    jieLing[xu] = jie
                }
            }
            else {
                let riXu = riShu+xu+1
                if let riJieLing = jieLing[riXu] {
                    jieLing[riXu] = riJieLing + " " + jie
                }
                else {
                    jieLing[riXu] = jie
                }
            }
        }
        
        yueQian = yueX - 1
        if (runF || yueX > nian.runYueX) {
            yueQian += 1
        }
    }
    
    static func deShuoRiGanZhi(shuoRiQi: Date) -> Int {
        let ganZhi = LI.ziJinLi.dateComponents([.day], from: Yue.BiaoDing_JiaZiRi, to: shuoRiQi).day!
        return Integer.mod(b: ganZhi, n: 60) + 1
    }
    
    static func deShuoRiQiZheng(shuoRiQi: Date) -> Int {
        let dayId: Int = LI.ziJinLi.component(.day, from: shuoRiQi)
        let weekDay: Int = LI.ziJinLi.component(.weekday, from: shuoRiQi)
        
        return Integer.mod(b: weekDay - dayId, n: 7) + 1
    }
    
     static func deRunYueFou(nian: Nian, yueX: Int, riQi: Date) -> Bool {
        if let _ = nian.runYueRiShu[yueX] {
            let dayId = LI.ziJinLi.component(.day, from: riQi)
            let ciHuiRi = LI.ziJinLi.date(bySetting: .day, value: (dayId < 29) ? 29 : dayId, of: riQi)!
            let nextSuDay = LI.ziJinLi.date(bySetting: .day, value: 1, of: ciHuiRi)!
            let nextMonthId = LI.ziJinLi.component(.month, from: nextSuDay)
            if nextMonthId != yueX {
                return true
            }
        }
        return false
    }
    
    static func getPrevMonth(year: Nian, month: Yue) -> Yue {
        return Yue(nian: year, riQi: Nian.QianHuiRi(date: month.shuoRiQi))
    }
    
    static func getNextMonth(year: Nian, month: Yue) -> Yue {
        return Yue(nian: year, riQi: Nian.CiShuoRi(date: month.shuoRiQi))
    }
    
    static var BiaoDing_JiaZiRi: Date {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return LI.ziJinLi.startOfDay(for: formatter.date(from:"1949-10-01T00:00:00+0800")!)
    }
}

struct NianYuan: Identifiable {
    var id: Int
    
    var nianFen: String // 年份
    var ganZhi: String // 干支
    
    var zhengTong_JiNian: Array<String> // 正統紀年
    var bieChao_JiNian: Array<String> // 別朝紀年
    
    var yueYuan_Ji: Array<YueYuan> = [] // 月元集
}

struct Nian {
    var yuanRiQi: Date // 元日期
    // MARK: -是為褒成宣尼紀元年份
    var nianX: Int // 年序
    
    var ganZhiX: Int // 干支序
    
    var liYueRiShu: Array<Int> = [] // 曆月日數
    var runYueRiShu: [Int: Int] = [:] // 閏月日數
    var runYueX: Int = 13 // 閏月序
    
    var zhengTong_JiNianX: Array<(guoHaoX: Int, nianHaoX: Int, nianX: Int)> = [] // 正统紀年「國號序、年號序、年序」
    var bieChao_JiNianX: Array<(guoHaoX: Int, nianHaoX: Int, nianX: Int)> = [] // 別朝紀年「國號序、年號序、年序」
    var yue_JiNianX: Dictionary<Int, Int> = [:] // 月紀年
    
    var yueLi: Array<Yue> = []
    
    func deNianYuan() -> NianYuan {
        let nianFen = (publicPresent ? "公元" : "褒成宣尼") + NumConverter.convert(nianX) + "年"
        let ganZhi = GanZhi.convert(ganZhiX)
        
        var zhengTong_JiNian: [String] = []
        var bieChao_JiNian: [String] = []
        
        for (guoHaoX, nianHaoX, nianX) in zhengTong_JiNianX {
            if guoHaoX == -1 || nianHaoX == -1 {
                zhengTong_JiNian.append(
                    Cina.GuoHaoBiao[0].guoHao + "前" + NumConverter.convert(nianX) + "年"
                )
            }
            else {
                let guoHao = Cina.GuoHaoBiao[guoHaoX].guoHao
                let nianHao = Cina.NianHaoBiao[guoHao]![nianHaoX].nianHao
                zhengTong_JiNian.append(
                    guoHao + nianHao + NumConverter.convert(nianX) + "年"
                )
            }
        }
        
        for (guoHaoX, nianHaoX, nianX) in bieChao_JiNianX {
            if guoHaoX == -1 || nianHaoX == -1 {
                bieChao_JiNian.append(
                    Cina.GuoHaoBiao[0].guoHao + "前" + NumConverter.convert(nianX) + "年"
                )
            }
            else {
                let guoHao = Cina.GuoHaoBiao[guoHaoX].guoHao
                let nianHao = Cina.NianHaoBiao[guoHao]![nianHaoX].nianHao
                bieChao_JiNian.append(
                    guoHao + nianHao + NumConverter.convert(nianX) + "年"
                )
            }
        }
        
        return NianYuan(id: nianX,
                        nianFen: nianFen,
                        ganZhi: ganZhi,
                        zhengTong_JiNian: zhengTong_JiNian,
                        bieChao_JiNian: bieChao_JiNian,
                        yueYuan_Ji: [])
    }
    
    init(date: Date) {
        yuanRiQi = Nian.YuanRi(date: date)
        nianX = LI.kongLi.component(.year, from: yuanRiQi)
        
//        ganZhiX = (nianFen - 4) % 60 + 1
        ganZhiX = LI.ziJinLi.component(.year, from: date)

        (liYueRiShu, runYueRiShu) = Nian.zhuYueRiShu(nianFen: nianX, yuanRiQi: yuanRiQi)
        for (xu, _) in runYueRiShu {
            runYueX = xu
        }
        
        var (xGuoHaoX, xNianHaoX, xNianX): (Int, Int, Int) = (-1, -1, 1)
        for yueX in (1 ..< 13) {
            // 紀年
            var (guoHaoX, nianHaoX, nianX) = Cina.GuoChao_JiNian(nianFen: nianX, yueFen: yueX, runYueF: false)
            if (guoHaoX, nianHaoX, nianX) != (xGuoHaoX, xNianHaoX, xNianX) {
                zhengTong_JiNianX.append((guoHaoX, nianHaoX, nianX))
            }
            yue_JiNianX[yueX] = zhengTong_JiNianX.count - 1
            
            if runYueRiShu.keys.contains(yueX) {
                (xGuoHaoX, xNianHaoX, xNianX) = (guoHaoX, nianHaoX, nianX)
                (guoHaoX, nianHaoX, nianX) = Cina.GuoChao_JiNian(nianFen: nianX, yueFen: yueX, runYueF: true)
                if (guoHaoX, nianHaoX, nianX) != (xGuoHaoX, xNianHaoX, xNianX) {
                    zhengTong_JiNianX.append((guoHaoX, nianHaoX, nianX))
                }
                yue_JiNianX[yueX + 12] = zhengTong_JiNianX.count - 1
            }
            (xGuoHaoX, xNianHaoX, xNianX) = (guoHaoX, nianHaoX, nianX)
        }
    }
    
    init(nianX: Int) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        yuanRiQi = Nian.YuanRi(date: formatter.date(from: String(nianX)+"-12-31T00:00:00+0800")!)
        
        self.nianX = nianX
        
        ganZhiX = Integer.mod(b: nianX-4, n: 60) + 1
        
        (liYueRiShu, runYueRiShu) = Nian.zhuYueRiShu(nianFen: nianX, yuanRiQi: yuanRiQi)
        for (xu, _) in runYueRiShu {
            runYueX = xu
        }
        
        var (xGuoHaoX, xNianHaoX, xJiNian_NianX): (Int, Int, Int) = (-1, -1, 1)
        for yueX in (1 ..< 13) {
            // 紀年
            var (guoHaoX, nianHaoX, jiNian_NianX) = Cina.GuoChao_JiNian(nianFen: nianX, yueFen: yueX, runYueF: false)
            if (guoHaoX, nianHaoX, jiNian_NianX) != (xGuoHaoX, xNianHaoX, xJiNian_NianX) {
                zhengTong_JiNianX.append((guoHaoX, nianHaoX, jiNian_NianX))
            }
            yue_JiNianX[yueX] = zhengTong_JiNianX.count - 1
            
            if runYueRiShu.keys.contains(yueX) {
                (xGuoHaoX, xNianHaoX, xJiNian_NianX) = (guoHaoX, nianHaoX, jiNian_NianX)
                (guoHaoX, nianHaoX, jiNian_NianX) = Cina.GuoChao_JiNian(nianFen: nianX, yueFen: yueX, runYueF: true)
                if (guoHaoX, nianHaoX, jiNian_NianX) != (xGuoHaoX, xNianHaoX, xJiNian_NianX) {
                    zhengTong_JiNianX.append((guoHaoX, nianHaoX, jiNian_NianX))
                }
                yue_JiNianX[yueX + 12] = zhengTong_JiNianX.count - 1
            }
            (xGuoHaoX, xNianHaoX, xJiNian_NianX) = (guoHaoX, nianHaoX, jiNian_NianX)
        }
    }
    
    static func ShuoRi(date: Date) -> Date {
        var suRi = LI.ziJinLi.startOfDay(for: date)
        var isSuRi = LI.ziJinLi.component(.day, from: suRi) == 1
        while (!isSuRi) {
            suRi = LI.ziJinLi.date(byAdding: .day, value: -1, to: suRi, wrappingComponents: false)!
            isSuRi = LI.ziJinLi.component(.day, from: suRi) == 1
        }
        return suRi
    }
    
    static func HuiRi(date: Date) -> Date {
        var huiRi = LI.ziJinLi.startOfDay(for: date)
        var suRi = LI.ziJinLi.date(byAdding: .day, value: 1, to: huiRi, wrappingComponents: false)!
        var isSuRi = LI.ziJinLi.component(.day, from: suRi) == 1
        while (!isSuRi) {
            huiRi = suRi
            suRi = LI.ziJinLi.date(byAdding: .day, value: 1, to: huiRi, wrappingComponents: false)!
            isSuRi = LI.ziJinLi.component(.day, from: suRi) == 1
        }
        return huiRi
    }
    
    static func CiShuoRi(date: Date) -> Date {
        let huiRi = Nian.HuiRi(date: date)
        return LI.ziJinLi.date(byAdding: .day, value: 1, to: huiRi, wrappingComponents: false)!
    }
    
    static func QianHuiRi(date: Date) -> Date {
        let suRi = Nian.ShuoRi(date: date)
        return LI.ziJinLi.date(byAdding: .day, value: -1, to: suRi, wrappingComponents: false)!
    }
    
    static func ZhengYue(date: Date) -> Date {
        var zhengYue = LI.ziJinLi.startOfDay(for: date)
        var laYue = LI.ziJinLi.date(byAdding: .month, value: -1, to: zhengYue)!
        var isLaYue = (LI.ziJinLi.component(.month, from: laYue) == 12) && (LI.ziJinLi.component(.month, from: zhengYue) == 1)
        while (!isLaYue) {
            zhengYue = laYue
            laYue = LI.ziJinLi.date(byAdding: .month, value: -1, to: zhengYue)!
            isLaYue = (LI.ziJinLi.component(.month, from: laYue) == 12) && (LI.ziJinLi.component(.month, from: zhengYue) == 1)
        }
        return zhengYue
    }
    
    static func LaYue(date: Date) -> Date {
        var laYue = LI.ziJinLi.startOfDay(for: date)
        var zhengYue = LI.ziJinLi.date(byAdding: .month, value: 1, to: laYue)!
        var isZhengYue = (LI.ziJinLi.component(.month, from: laYue) == 12) && (LI.ziJinLi.component(.month, from: zhengYue) == 1)
        while (!isZhengYue) {
            laYue = zhengYue
            zhengYue = LI.ziJinLi.date(byAdding: .month, value: 1, to: laYue)!
            isZhengYue = (LI.ziJinLi.component(.month, from: laYue) == 12) && (LI.ziJinLi.component(.month, from: zhengYue) == 1)
        }
        return laYue
    }
    
    static func YuanRi(date: Date) -> Date {
        return Nian.ZhengYue(date: Nian.ShuoRi(date: date))
    }
    
    static func ChuRi(date: Date) -> Date {
        var xiaoHuiRi = LI.ziJinLi.startOfDay(for: date)
        if LI.ziJinLi.component(.day, from: xiaoHuiRi) == 30 {
            xiaoHuiRi = LI.ziJinLi.date(byAdding: .day, value: -1, to: xiaoHuiRi, wrappingComponents: false)!
        }
        return Nian.HuiRi(date: Nian.LaYue(date: xiaoHuiRi))
    }
    
    static func zhuYueRiShu(nianFen: Int, yuanRiQi: Date) -> (Array<Int>, [Int: Int]) {
        var numOfDaysList: Array<Int> = []
        var leapMonthsList: [Int: Int] = [:]
        
        var shuoRiQi = yuanRiQi
        
        var monthId: Int = 1
        for _ in 0..<12 {
//            firstDate = firstDate.advanced(by: 29 * 86400)
            shuoRiQi = Calendar.current.date(byAdding: .day, value: 29, to: shuoRiQi, wrappingComponents: false)!
            var nextMonthId = LI.ziJinLi.component(.month, from: shuoRiQi)
            let nextDayId = LI.ziJinLi.component(.day, from: shuoRiQi)
            if nextDayId == 1 {
                numOfDaysList.append(29)
            }
            else if nextDayId == 30{
                numOfDaysList.append(30)
//                firstDate = firstDate.advanced(by: 1 * 86400)
                shuoRiQi = Calendar.current.date(byAdding: .day, value: 1, to: shuoRiQi, wrappingComponents: false)!
                nextMonthId = LI.ziJinLi.component(.month, from: shuoRiQi)
            }
            else {
                exit(1)
            }
            if nextMonthId == monthId || Cina.runYueNianBiao[nianFen] == monthId {
//                firstDate = firstDate.advanced(by: 29 * 86400)
                shuoRiQi = Calendar.current.date(byAdding: .day, value: 29, to: shuoRiQi, wrappingComponents: false)!
                let nextDayId = LI.ziJinLi.component(.day, from: shuoRiQi)
                if nextDayId == 1 {
                    leapMonthsList[monthId] = 29
                }
                else if nextDayId == 30{
                    leapMonthsList[monthId] = 30
//                    firstDate = firstDate.advanced(by: 1 * 86400)
                    shuoRiQi = Calendar.current.date(byAdding: .day, value: 1, to: shuoRiQi, wrappingComponents: false)!
                }
            }
            monthId += 1
            // check dayId == 1
        }
        
        return (numOfDaysList, leapMonthsList)
    }
    
}

struct Cina {
    static func GuoChao_JiNian(nianFen: Int, yueFen: Int, runYueF: Bool) -> (Int, Int, Int) {
        var (guoHao, nianHao, nianHaoNianFeng): (String, String, Int)
        var (guoHaoX, nianHaoX, nianHaoNianX): (Int, Int, Int)
        let (shouNian, shouYue, shouYueRunF, _) = Cina.GuoHaoBiao[0]
        if ((nianFen < shouNian) ||
            (nianFen == shouNian && yueFen < shouYue) ||
            (nianFen == shouNian && yueFen == shouYue && !runYueF && shouYueRunF)) {
//            guoHao = Cina.GuoHaoBiao[0].dynasty
//            nianHao = "前"
//            nianHaoNianFeng = shouNian - nianFen + 1
            
            return (-1, -1, shouNian - nianFen + 1)
        }
        var (jianGuo_NianFen, jianGuo_YueFen, jianGuo_RunYueF, jianGuo_GuoHao): (Int, Int, Bool, String)
        var xGuoHao = Cina.GuoHaoBiao[0].guoHao
        var xGuoHaoX = 0
        for x in (0 ..< Cina.GuoHaoBiao.count) {
            (jianGuo_NianFen, jianGuo_YueFen, jianGuo_RunYueF, jianGuo_GuoHao) = Cina.GuoHaoBiao[x]
            if ((nianFen < jianGuo_NianFen) ||
                (nianFen == jianGuo_NianFen && yueFen < jianGuo_YueFen) ||
                (nianFen == jianGuo_NianFen && yueFen == jianGuo_YueFen && !runYueF && jianGuo_RunYueF )) {
                
                break
            }
            else {
                xGuoHao = jianGuo_GuoHao
                xGuoHaoX = x
            }
        }

        guoHao = xGuoHao
        guoHaoX = xGuoHaoX
        var (gaiYuan_NianFen, gaiYuan_YueFen, gaiYuan_RunYueF, gaiYuan_NianHao): (Int, Int, Bool, String)
        var (xGaiYuan_NianFen, xGaiYuan_YueFen, xGaiYuan_RunYueF, xGaiYuan_NianHao) = Cina.NianHaoBiao[guoHao]![0]
        var xNianHaoX = 0
        var (gaiYuan_JianNian, gaiYuan_JianYue, gaiYuan_JianRunYueF, _) = Cina.NianHaoBiao[guoHao]![0]
        for xu_2 in (0 ..< Cina.NianHaoBiao[guoHao]!.count) {
            (gaiYuan_NianFen, gaiYuan_YueFen, gaiYuan_RunYueF, gaiYuan_NianHao) = Cina.NianHaoBiao[guoHao]![xu_2]
            (gaiYuan_JianNian, gaiYuan_JianYue, gaiYuan_JianRunYueF) = (gaiYuan_NianFen, gaiYuan_YueFen, gaiYuan_RunYueF)
            if (gaiYuan_JianYue < 0) {
                (gaiYuan_JianNian, gaiYuan_JianYue) = (gaiYuan_JianNian-1, -gaiYuan_JianYue)
            }
            if ((nianFen < gaiYuan_JianNian) ||
                (nianFen == gaiYuan_JianNian && yueFen < gaiYuan_JianYue) ||
                (nianFen == gaiYuan_JianNian && yueFen == gaiYuan_JianYue && !runYueF && gaiYuan_JianRunYueF )) {
                
                break
            }
            else {
                (xGaiYuan_NianFen, xGaiYuan_YueFen, xGaiYuan_RunYueF, xGaiYuan_NianHao) = Cina.NianHaoBiao[guoHao]![xu_2]
                xNianHaoX = xu_2
            }
        }
        
        nianHao = xGaiYuan_NianHao
        nianHaoX = xNianHaoX
//        xGaiYuan_YueFen = (xGaiYuan_YueFen < 0) ? -xGaiYuan_YueFen : xGaiYuan_YueFen
        if let fuPi_NianHao_YuanNian = Cina.FupiNianhao[nianHao] {
            nianHaoNianFeng = nianFen - fuPi_NianHao_YuanNian + 1
        }
        else {
            nianHaoNianFeng = nianFen - xGaiYuan_NianFen + 1
        }
        if (( xGaiYuan_YueFen < 0)                                                 &&
            ( ( yueFen > -xGaiYuan_YueFen )                                    ||
              ( yueFen == -xGaiYuan_YueFen && (runYueF || !xGaiYuan_RunYueF) )    )    ) {
            nianHaoNianFeng += 1
        }
        
        nianHaoNianX = nianHaoNianFeng
        return (guoHaoX, nianHaoX, nianHaoNianX)
    }
    
    // MARK: -使用褒成宣尼紀元年份
    static let runYueNianBiao: Dictionary<Int, Int> = [1949:7, 1952:5, 1955:3, 1957:8, 1960:6, 1963:4, 1966:3, 1968:7,
                                                      1971:5, 1974:4, 1976:8, 1979:6, 1982:4, 1984:10, 1987:6,
                                                      1990:5, 1993:3, 1995:8, 1998:5, 2001:4, 2004:2, 2006:7,
                                                      2009:5, 2012:4, 2014:9, 2017:6, 2020:4, 2023:2, 2025:6,
                                                      2028:5, 2031:3, 2033:11, 2036:6, 2039:5, 2042:2, 2044:7,
                                                      2047:5, 2050:3]
    
    static let runZhengYueNianBiao: Set<Int> = [8, 27, 103, 141, 160, 179, 217, 331, 369, 388, 426, 600, 657, 687, 706, 763, 782, 801, 820, 839, 1048, 1116, 1173, 1268, 1306, 1317, 1355, 1420, 1488, 1507, 1545, 1640, 2262, 2357, 2520, 2539, 2634, 4103, 4828, 4923, 5868, 6088, 6183, 6240, 6278, 6460, 6555, 6612, 6650, 6832, 6984, 7022, 7041, 7166, 7242, 7424, 7519, 7538, 7614, 7633, 7796, 7891, 7910, 7986, 8005, 8206, 8377, 8388, 8578, 8760, 8798, 8855, 8874, 8950, 8969, 9132, 9170, 9208, 9227, 9322, 9341, 9390, 9523, 9542, 9580, 9599, 9610, 9618, 9705, 9713, 9724, 9762, 9800, 9838, 9914, 9933, 9982]
    
    static let GuoHaoBiao: Array<(year: Int, month: Int, isleap: Bool, guoHao: String)> = [
        (1368, 1, false, "明虞"),
        (1644, 1, false, "清震"),
        (1911, 11, false, "華")
    ]
    
    static let NianHaoBiao: Dictionary<String, Array<(Int, Int, Bool, nianHao: String)>> = [
        "明虞": [(1368, 1, false, "洪武"),
                (1399, 1, false, "建文"),
                (1402, 7, false, "洪武"),
                (1403, 1, false, "永樂"),
                (1425, 1, false, "洪熙"),
                (1426, 1, false, "宣德"),
                (1436, 1, false, "正統"),
                (1450, 1, false, "景泰"),
                (1457, 1, false, "天順"),
                (1465, 1, false, "成化"),
                (1488, 1, false, "弘治"),
                (1506, 1, false, "正德"),
                (1522, 1, false, "嘉靖"),
                (1567, 1, false, "隆慶"),
                (1573, 1, false, "萬曆"),
                (1620, 8, false, "泰昌"),
                (1621, 1, false, "天啟"),
                (1628, 1, false, "崇禎")
        ],
        "清震": [(1636, 4, false, "崇德"),
                (1644, 1, false, "順治"),
                (1662, 1, false, "康熙"),
                (1723, 1, false, "雍正"),
                (1736, 1, false, "乾隆"),
                (1796, 1, false, "嘉慶"),
                (1821, 1, false, "道光"),
                (1851, 1, false, "咸豐"),
                (1862, 1, false, "同治"),
                (1875, 1, false, "光緒"),
                (1909, 1, false, "宣統")
        ],
        "華": [(1912, -11, false, "民國"),
                (1949, 8, false, "人民共和")
        ]
        
    ]
    
    static let FupiNianhao: Dictionary<String, Int> = [
        "洪武": 1368
    ]
    
    static let YueName: Array<String> = [
        "正月", "二月", "三月", "四月", "五月", "六月",
        "七月", "八月", "九月", "十月", "冬月", "臘月",
        "閏正月", "閏二月", "閏三月", "閏四月", "閏五月", "閏六月",
        "閏七月", "閏八月", "閏九月", "閏十月", "閏冬月", "閏臘月"
    ]
    
    static let RiName = ["初一", "初二", "初三", "初四", "初五", "初六", "初七", "初八", "初九", "初十",
                          "十一", "十二", "十三", "十四", "十五", "十六", "十七", "十八", "十九", "二十",
                          "廿一", "廿二", "廿三", "廿四", "廿五", "廿六", "廿七", "廿八", "廿九", "三十"]
    
    static let JieQi: Array<String> = []
    
    // MARK: -以月令確定的節日
    static let YueLingJieRi: Array<Dictionary<Int, String>> = [
        // 正月
        [1:"元旦", 7:"人節", 15:"上元", -1:"初晦"],
        // 二月
        [1:"中和", 15:"花朝"],
        // 三月
        [3:"上巳"],
        // 四月
        [:],
        // 五月
        [5:"端午"],
        // 六月
        [:],
        // 七月
        [7:"七夕", 15:"中元"],
        // 八月
        [10:"開國", 15:"中秋", 27:"孔誕"],
        // 九月
        [9:"重陽"],
        // 十月
        [1:"寒衣", 15:"下元"],
        // 冬月
        [11:"冬祭"],
        // 臘月
        [8:"臘八",  -1:"除夕"],
    ]
    
    // MARK: -以節氣確定的節日，如：冬祭
    static let JieQiJieRi: [String:(String, Int)] = [:]
    
    // MARK: -以月令前後地支確定的節日，如：端午（五月第一個午日）
    static let DiZhiJieRi: [Int:(String,Int)] = [:]
    
    // MARK: -以節氣前後地支確定的節日，如：春社、秋社
    static let JieQiDiZhiJieRi: [String:(String,Int)] = [:]
}

struct NumConverter {
    static func convert(_ number: Int) -> String {
        var CinaNum: String
        
        var num: Int = number
        if num < 0 {
            num = -num
        }
        if num == 1 {
            return "元"
        }
        if number <= 10 {
            CinaNum = digitList[number]
        }
        else if number <= 100 {
            if number == 100 {
                CinaNum = "一百"
            }
            else {
                CinaNum =  "十"
                if number / 10 != 1 {
                    CinaNum = digitList[num/10] + CinaNum
                }
                if number % 10 != 0 {
                    CinaNum =  CinaNum + digitList[num%10]
                }
            }
        }
        else {
            CinaNum = ""
            while num > 0 {
                CinaNum = digitList[num % 10] + CinaNum
                num /= 10
            }
        }
        
        return CinaNum
    }
    
    static func translate(_ number: Int) -> String {
        var CinaNum: String = ""
        var num: Int = number
        if num < 0 {
            num = -num
        }
        
        if number <= 10 {
            CinaNum = digitList[number]
        }
        else if number <= 100000 {
            var digit = num % 10
            if digit != 0{
                CinaNum = digitList[num % 10]
            }
            num /= 10
            
            
            var hasZero: Bool
            var level: Int = 0
            while num > 0 {
                hasZero = digit == 0
                
                digit = num % 10
                if digit == 0 {
                    if !hasZero {
                        CinaNum = "〇" + CinaNum
                    }
                }
                else {
                    CinaNum = expList[level] + CinaNum
                    if digit != 1 || level != 0 {
                        CinaNum = digitList[digit] + CinaNum
                    }
                }
                num /= 10
                level += 1
            }
        }
        
        if number < 0 {
            CinaNum = "前"
            num = -number
        }
        return CinaNum
    }
    
    static let digitList: Array<String> = ["〇", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"]
    static let expList: Array<String> = ["十", "百", "千", "萬"]
}

struct GanZhi {
    static func convert(_ number: Int) -> String {
        return TianGan[Integer.mod(b:(number-1), n:10)] + DiZhi[Integer.mod(b:(number-1), n:12)]
    }
    
    static func convert(tianGan: Int, diZhi: Int) -> String {
        return TianGan[tianGan-1] + DiZhi[diZhi-1]
    }
    
    static let TianGan: Array<String> = ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"]
    static let DiZhi: Array<String> = ["子", "丑", "寅", "卯", "辰", "巳", "午", "未", "申", "酉", "戌", "亥"]
}


struct Integer {
    static func mod(b: Int, n: Int) -> Int {
        if (n == 0 || n == 1) {
            return 0
        }

        let (a, m) = (n > 0) ? (b, n) : (-b, -n)
        if (a >= 0) {
            return a % m
        }
        else {
            return (m - ((-a) % m)) % m
        }
    }
}
