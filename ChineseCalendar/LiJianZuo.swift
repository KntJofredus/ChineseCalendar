//
//  ChineseCalendar.swift
//  ChineseCalendar
//
//  Created by Junyi Qiu on 2021/6/10.
//

import SwiftUI

class LiJianZuo: ObservableObject {
    @Published private var li: LI
    
    init(date: Date = Date()) {
        self.li = LI(date)
    }
    
    
    // MARK: - Intent
    func chooseDay(_ riQ: Int) -> Void {
         li.zeRi(riQ)
    }
    
    func backwardMonth() -> Void {
        li.zeYue(.ShangYue)
    }
    
    func forwardMonth() -> Void {
        li.zeYue(.CiYue)
    }
    
    func QuNian() -> Void {
        li.zeNian(.QuNian)
    }
    
    func CiNian() -> Void {
        li.zeNian(.CiNian)
    }
    
    // MARK: - Access
    var nianSanYe: Array<NianYuan> {
        li.nianSanYe
    }
    
    var yueSanYe: Array<YueYuan> {
        li.yueSanYe
    }
    
    var dangNian: NianYuan {
        li.nianSanYe[1]
    }
    
    var nianFeng: String {
        li.nianSanYe[1].nianFen
    }
    
    var dangYueJiNian: String {
        li.yueSanYe[1].dangYue_JiNian
    }
    
    var zhengTong_JiNian: Array<String> {
        li.nianSanYe[1].zhengTong_JiNian
    }
    
    var bieChao_JiNian: Array<String> {
        li.nianSanYe[1].bieChao_JiNian
    }
    
    var yue_Ji: Array<YueYuan> {
        li.yueSanYe
    }
    
    var dangYue: YueYuan {
        li.yueSanYe[1]
    }
    
    
    var dangRi: RiYuan {
        li.dangRi.deRiYuan()
    }
}
