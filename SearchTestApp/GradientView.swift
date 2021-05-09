//
//  GradientView.swift
//  SearchTestApp
//
//  Created by Olga Trofimova on 09.05.2021.
//

import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clear
    }
    
    
// ПРИМЕЧАНИЕ:  В целом создавать новые объекты внутри метода draw (), такие как градиенты, неоптимально, особенно если draw () вызывается часто.
//    В таких случаях лучше создавать объекты в первый раз, когда они понадобятся, и повторно использовать один и тот же экземпляр. 
    
    override func draw(_ rect: CGRect) {
//проверяем информацию о внешнем виде системы и в зависимости отз начения выставляем цвет градиента
        let traits = UITraitCollection.current
        let color: CGFloat = traits.userInterfaceStyle == .light ? 0.314 : 1
//создаем два массива, которые определяют, как будет отображаться градиент.
//Градиент рисуется с использованием набора цветов и остановок/местоположений.
//Начинаем с первого места с первым цветом и рисуем, пока не доберемся до второго места, а затем переключаемся на второй цвет и рисуем, пока не доберемся до третьего места и т.д.
//  Первый массив, components, дает цвета, которые будут использоваться в градиенте, а второй массив, location, дает точки вдоль пути градиента, где мы хотим, чтобы произошли изменения цвета.
//    Рисование начнется в центре экрана, потому что рисуем круговой градиент.
        
        let components: [CGFloat] = [
            color,  color, color, 0.2,
            color,  color, color, 0.4,
            color,  color, color, 0.6,
            color,  color, color, 1,
        ]
        let locations: [CGFloat] = [0, 0.5, 0.75, 1]

//объект градиенты
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 4)
        
//Нужно определить какого размера градиент рисовать.
//  Свойства midX и midY возвращают центральную точку прямоугольника. Этот прямоугольник задается границей, объектом CGRect, который описывает размеры представления.
// Используя границы, можно использовать это представление где угодно, независимо от того, насколько большое пространство оно должно заполнять (от самого маленького iPhone до самого большого iPad)
//   centerPoint содержит координаты центральной точки обзора, а радиус - большее из значений x и y.
        let x = bounds.midX
        let y = bounds.midY
        let centerPoint = CGPoint(x: x, y: y)
        let radius = max(x, y)

//      Чтобы рисовать нужно получить ссылку на графический контекст
        let context = UIGraphicsGetCurrentContext()
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
    }
    
}
