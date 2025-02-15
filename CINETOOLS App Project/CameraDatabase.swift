//
//  CameraDatabase.swift
//  New Camera Tools App
//
//  Created by steven mann on 30/01/2025.
//

import Foundation

class CameraDatabase {
    static let shared = CameraDatabase() // Singleton instance
    
    let brands: [CameraData] = [
        CameraData(name: "Sony", models: [
            CameraModel(name: "FX6", powerDraw: 19, codecs: [
                CodecData(name: "XAVC-I 4K 25fps", bitrate: 250),
                CodecData(name: "XAVC-I 4K 50fps", bitrate: 500),
                CodecData(name: "XAVC-I HD 25fps", bitrate: 112),
                CodecData(name: "XAVC-I HD 50fps", bitrate: 223),
                CodecData(name: "XAVC-L QFHD 25fps", bitrate: 100),
                CodecData(name: "XAVC-L QFHD 50fps", bitrate: 150),
                CodecData(name: "XAVC-L HD 25fps", bitrate: 35),
                CodecData(name: "XAVC-L HD 50fps", bitrate: 50)
            ]),
            CameraModel(name: "FX3", powerDraw: 7.7, codecs: [
                CodecData(name: "XAVC S 4K 25fps", bitrate: 140),
                CodecData(name: "XAVC S 4K 50fps", bitrate: 200),
                CodecData(name: "XAVC S HD 25fps", bitrate: 50),
                CodecData(name: "XAVC S HD 25fps", bitrate: 50),
                CodecData(name: "XAVC S-I 4K 25fps", bitrate: 250),
                CodecData(name: "XAVC S-I 4K 50fps", bitrate: 500),
                CodecData(name: "XAVC S-I HD 25fps", bitrate: 93),
                CodecData(name: "XAVC S-I HD 50fps", bitrate: 185),
            ]),
            CameraModel(name: "FX9", powerDraw: 35.2, codecs: [
                CodecData(name: "XAVC-I QFHD 25p", bitrate: 250),
                CodecData(name: "XAVC-I QFHD 50p", bitrate: 500),
                CodecData(name: "XAVC-I HD 25p", bitrate: 112),
                CodecData(name: "XAVC-I HD 50p", bitrate: 223),
                CodecData(name: "XAVC-L QFHD 25fps", bitrate: 100),
                CodecData(name: "XAVC-L QFHD 50fps", bitrate: 150),
                CodecData(name: "XAVC-L HD 25/50fps", bitrate: 50)
          //  ]),
          //  CameraModel(name: "Burano", powerDraw: 50, codecs: [
          //      CodecInfo(name: "XAVC-I 4K", bitrate: 600),
          //      CodecInfo(name: "XAVC-L 4K", bitrate: 150)

            ]),
            CameraModel(name: "Venice", powerDraw: 65, codecs: [
                CodecData(name: "6K 3:2 25fps X-OCN XT", bitrate: 343),
                CodecData(name: "6K 3:2 25fps X-OCN ST", bitrate: 234),
                CodecData(name: "6K 3:2 50fps X-OCN ST", bitrate: 468),
                CodecData(name: "6K 3:2 25fps X-OCN LT", bitrate: 138),
                CodecData(name: "6K 3:2 50fps X-OCN LT", bitrate: 276),
                CodecData(name: "3.8K 16:9 25fps X-OCN XT", bitrate: 125),
                CodecData(name: "3.8K 16:9 50fps X-OCN XT", bitrate: 251),
                CodecData(name: "3.8K 16:9 25fps X-OCN ST", bitrate: 86),
                CodecData(name: "3.8K 16:9 50fps X-OCN ST", bitrate: 172),
                CodecData(name: "3.8K 16:9 25fps X-OCN LT", bitrate: 50),
                CodecData(name: "3.8K 16:9 50fps X-OCN LT", bitrate: 101),
                CodecData(name: "2K 16:9 25fps ProRess4444", bitrate: 39),
                CodecData(name: "2K 16:9 25fps ProRess 422HQ", bitrate: 26),
                CodecData(name: "2K 16:9 50fps ProRess 422HQ", bitrate: 53)
            ])
        ]),
        CameraData(name: "Canon", models: [
            CameraModel(name: "C70", powerDraw: 19, codecs: [
                CodecData(name: "XF-AVC 4K", bitrate: 410),
                CodecData(name: "MP4 4K", bitrate: 230),
                CodecData(name: "XF-AVC HD", bitrate: 160)
            ]),
            CameraModel(name: "C300 III", powerDraw: 25.2, codecs: [
                CodecData(name: "XF-AVC 4K", bitrate: 810),
                CodecData(name: "Cinema RAW Light", bitrate: 1000),
                CodecData(name: "XF-AVC HD", bitrate: 160)
            ]),
            CameraModel(name: "C500 II", powerDraw: 32.8, codecs: [
                CodecData(name: "Cinema RAW Light", bitrate: 556),
                CodecData(name: "Cinema RAW Light HQ", bitrate: 1770),
                CodecData(name: "XF-AVC 4K", bitrate: 410)
            ]),
            CameraModel(name: "R5C", powerDraw: 13.3, codecs: [
                CodecData(name: "12-bit Cinema RAW Light LT 8K 25fps", bitrate: 1070),
                CodecData(name: "12-bit Cinema RAW Light LT 8K 50fps", bitrate: 2140),
                CodecData(name: "12-bit Cinema RAW Light LT 5.9K 25fps", bitrate: 556),
                CodecData(name: "12-bit Cinema RAW Light LT 5.9K 50fps", bitrate: 1140),
                CodecData(name: "12-bit Cinema RAW Light ST 8K 25fps", bitrate: 1650),
                CodecData(name: "12-bit Cinema RAW Light ST 5.9K 25fps", bitrate: 871),
                CodecData(name: "12-bit Cinema RAW Light ST 5.9K 50fps", bitrate: 1750),
                CodecData(name: "12-bit Cinema RAW Light HQ 5.9K 25fps", bitrate: 1770),
                CodecData(name: "XF-AVC-I 4:2:2 10-bit 4K 25fps", bitrate: 410),
                CodecData(name: "XF-AVC-I 4:2:2 10-bit 4K 50fps", bitrate: 810),
                CodecData(name: "XF-AVC-L 4:2:2 10-bit 4K 25fps", bitrate: 160),
                CodecData(name: "XF-AVC-L 4:2:2 10-bit 4K 50fps", bitrate: 260),
                CodecData(name: "HEVC-L (MP4) 4:2:2 10-bit 8K 25fps", bitrate: 540),
                CodecData(name: "HEVC-L (MP4) 4:2:2 10-bit 4K 25fps", bitrate: 135),
                CodecData(name: "HEVC-L (MP4) 4:2:0 10-bit 8K 25fps", bitrate: 400),
                CodecData(name: "HEVC-L (MP4) 4:2:0 10-bit 4K 25fps", bitrate: 100),
                
                
            ])
        ]),
        CameraData(name: "ARRI", models: [
            CameraModel(name: "Alexa Mini", powerDraw: 65, codecs: [
                CodecData(name: "ProRes 4444 XQ 25fps", bitrate: 1858),
                CodecData(name: "ProRes 4444 25fps", bitrate: 1239),
                CodecData(name: "ProRes 422 HQ 25fps", bitrate: 826),
                CodecData(name: "ProRes 422 25fps", bitrate: 551),
                CodecData(name: "ARRIRAW 2.8K 25fps", bitrate: 1400),
                CodecData(name: "ARRIRAW OG 3.4K 25fps", bitrate: 2262)
            ]),
            CameraModel(name: "Alexa 35", powerDraw: 85, codecs: [
                CodecData(name: "ARRIRAW 4.6K 3:2 OG 25fps", bitrate: 4644),
                CodecData(name: "ProRes 422HQ 4.6K 3:2 OG 25fps", bitrate: 1276),
                CodecData(name: "ProRes 4444 4.6K 3:2 OG 25fps", bitrate: 1907),
                CodecData(name: "ProRes 4444XQ 4.6K 3:2 OG 25fps", bitrate: 2852)
            ]),
            CameraModel(name: "Alexa Mini LF", powerDraw: 85, codecs: [
                CodecData(name: "ARRIRAW 4.5K 3:2 OG 25fps", bitrate: 4036),
                CodecData(name: "ProRes 422HQ 4.5K 3:2 OG 25fps", bitrate: 1226),
                CodecData(name: "ProRes 4444 4.5K 3:2 OG 25fps", bitrate: 1839),
                CodecData(name: "ProRes 4444XQ 4.5K 3:2 OG 25fps", bitrate: 2725),
                CodecData(name: "ProRes 422HQ 3.2K S35 25fps", bitrate: 499),
                CodecData(name: "ProRes 4444 3.2K S35 25fps", bitrate: 748),
                CodecData(name: "ARRIRAW 3.2K S35 25fps", bitrate: 2210),
            ]),
            CameraModel(name: "Amira", powerDraw: 84, codecs: [
                CodecData(name: "ProRes 4444XQ 4K S35 25fps", bitrate: 1861),
                CodecData(name: "ProRes 4444 4K S35 25fps", bitrate: 1241),
                CodecData(name: "ProRes 422HQ 4K S35 25fps", bitrate: 829),
                CodecData(name: "ARRIRAW 2.8K S35 25fps", bitrate: 1407)
            ])
        ]),
        CameraData(name: "RED", models: [
            CameraModel(name: "Komodo", powerDraw: 37, codecs: [
              //  CodecInfo(name: "REDCODE RAW LQ", bitrate: 2800),
              //  CodecInfo(name: "REDCODE RAW MQ", bitrate: 2200),
                CodecData(name: "REDCODE RAW HQ", bitrate: 280)
            ]),
            CameraModel(name: "V-Raptor", powerDraw: 75, codecs: [
               // CodecInfo(name: "REDCODE RAW HQ", bitrate: 3200),
              //  CodecInfo(name: "REDCODE RAW MQ", bitrate: 2400),
              //  CodecInfo(name: "REDCODE RAW LQ", bitrate: 1800),
                CodecData(name: "ProRes 422 HQ", bitrate: 800)
            ]),
            CameraModel(name: "V-Raptor XL", powerDraw: 75, codecs: [
               // CodecInfo(name: "REDCODE RAW HQ", bitrate: 3200),
               // CodecInfo(name: "REDCODE RAW MQ", bitrate: 2400),
               // CodecInfo(name: "REDCODE RAW LQ", bitrate: 1800),
                CodecData(name: "ProRes 422 HQ", bitrate: 800)
            ])
        ]),
        CameraData(name: "Blackmagic", models: [
            CameraModel(name: "Pocket 4K", powerDraw: 22, codecs: [
                CodecData(name: "Blackmagic RAW 3:1 4K 30fps", bitrate: 136),
                CodecData(name: "ProRes 422HQ 4K 30fps", bitrate: 117)
            ]),
            CameraModel(name: "Pocket 6K", powerDraw: 26, codecs: [
                CodecData(name: "Blackmagic RAW 3:1 6K 30fps", bitrate: 323),
                CodecData(name: "Blackmagic RAW 3:1 4K 30fps", bitrate: 136),
                CodecData(name: "ProRes 422HQ 4K 30fps", bitrate: 117)
            ]),
            CameraModel(name: "Ursa Mini Pro 12K", powerDraw: 55, codecs: [
                CodecData(name: "Blackmagic RAW 5:1 12K 24fps", bitrate: 578),
                CodecData(name: "Blackmagic RAW 5:1 8K 24fps", bitrate: 257),
                CodecData(name: "Blackmagic RAW 5:1 4K 24fps", bitrate: 161),
                CodecData(name: "Blackmagic Raw 5:1 4K S16 240fps", bitrate: 648)
            ])
        ]),
        CameraData(name: "Fujifilm", models: [
            CameraModel(name: "X-H2S", powerDraw: 13, codecs: [
                CodecData(name: "6.2K 3:2 25fps", bitrate: 360),
                CodecData(name: "4K 25fps", bitrate: 200),
                CodecData(name: "4K 50fps", bitrate: 360),
                CodecData(name: "HD 25fps", bitrate: 200),
                CodecData(name: "HD 50fps", bitrate: 360),
                CodecData(name: "4k Hi Speed 120fps", bitrate: 720)
            ])
        ]),
        CameraData(name: "Nikon", models: [
            CameraModel(name: "Z9", powerDraw: 7.5, codecs: [
                CodecData(name: "N-RAW 4K 25fps", bitrate: 730),
                CodecData(name: "N-RAW 4K 50fps", bitrate: 1450),
                CodecData(name: "N-RAW 8K 25fps", bitrate: 2410),
                CodecData(name: "N-RAW 8K 50fps", bitrate: 4810)
            ])
        ]),
        CameraData(name: "Kinefinity", models: [
            CameraModel(name: "Terra 4K", powerDraw: 23, codecs: [
                CodecData(name: "4K 25fps ProRes4444", bitrate: 250)
                
            ]),
            CameraModel(name: "Mavo LF", powerDraw: 27, codecs: [
                CodecData(name: "6K 25fps ProRes4444", bitrate: 350)
            ])
        ])
    ]
    
    let accessories: [Accessory] = [
        // Monitors
        Accessory(name: "Atomos Ninja V 5''", powerDraw: 20, category: .monitor),
        Accessory(name: "Feelworld F6 Plus", powerDraw: 9, category: .monitor),
        Accessory(name: "Portkeys PT5 II 5''", powerDraw: 7, category: .monitor),
        Accessory(name: "SmallHD Cine 5''", powerDraw: 19, category: .monitor),
        Accessory(name: "SmallHD Cine 7''", powerDraw: 20, category: .monitor),
        Accessory(name: "SmallHD Cine 7 Ultra", powerDraw: 19, category: .monitor),
        
        // Wireless Video
        Accessory(name: "Hollyland Mars 300", powerDraw: 11, category: .wireless),
        Accessory(name: "Hollyland Mars 400s Pro ii", powerDraw: 11, category: .wireless),
        Accessory(name: "SWIT FLOW2000", powerDraw: 8, category: .wireless),
        Accessory(name: "Teradek Bolt 4K 750", powerDraw: 30, category: .wireless),
        Accessory(name: "Teradek Bolt 6 LT", powerDraw: 10, category: .wireless),
        Accessory(name: "Teradek Bolt 6", powerDraw: 9, category: .wireless),
        Accessory(name: "Teradek Bolt 4K Max", powerDraw: 15, category: .wireless),
        Accessory(name: "Vaxis ATOM 600", powerDraw: 6.5, category: .wireless),
        
        // Focus Systems
        Accessory(name: "DJI Focus Pro", powerDraw: 6.8, category: .focus),
        Accessory(name: "PDMOVIE Live Air 3", powerDraw: 7, category: .focus),
        Accessory(name: "Tilta Nucleus M", powerDraw: 20, category: .focus),
        //Accessory(name: "ARRI WCU-4", powerDraw: 7, category: .focus),
        //Accessory(name: "Preston HU4", powerDraw: 8, category: .focus),
        
        // Assorted
        Accessory(name: "Audio - Tentacle Sync E", powerDraw: 0.5, category: .assorted),
        Accessory(name: "Audio - Zoom F3", powerDraw: 5, category: .assorted)
    ]
    
    // Helper method to get camera for battery calculator
    func getCameraForBatteryCalc() -> [CameraBrand] {
        return brands.map { brandInfo in
            CameraBrand(name: brandInfo.name, models: brandInfo.models.map { model in
                Camera(model: model.name, powerDraw: model.powerDraw)
            })
        }
    }
    
    // Helper method to get camera data for data calculator
    func getCameraForDataCalc() -> [CameraData] {
        return brands
    }
    
    // Add helper method for accessories
    func getAccessories() -> [Accessory] {
        return accessories
    }
    
    private init() {} // Private initializer for singleton
} 
