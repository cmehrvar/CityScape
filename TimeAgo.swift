
import Foundation

public func timeAgoSince(date: NSDate, showAccronym: Bool) -> String {
    
    let calendar = NSCalendar.current
    let now = NSDate()

    let unitFlags = Set<Calendar.Component>([.second, .minute, .hour, .day, .weekOfYear, .month, .year])
    
    let components = calendar.dateComponents(unitFlags, from: date as Date, to: now as Date)
    
    if let year = components.year {
        
        if year >= 2 {
            
            if showAccronym {
                return "\(year)y"
            } else {
                return "\(year)"
            }
        }
        
        if year >= 1 {
            
            if showAccronym {
                return "1y"
            } else {
                return "1"
            }
        }
    }
    
    if let month = components.month {
        
        if month >= 2 {
            return "\(month)m"
        }
        
        if month >= 1 {
            return "1m"
        }
    }
    
    if let week = components.weekOfYear {
        
        if week >= 2 {
            return "\(week)w"
        }
        
        if week >= 1 {
            return "1w"
        }
    }
    
    if let day = components.day {
        
        if day >= 2 {
            return "\(day)d"
        }
        
        if day >= 1 {
            return "1d"
        }
        
    }
    
    if let hour = components.hour {
        
        if hour >= 2 {
            return "\(hour)h"
        }
        
        if hour >= 1 {
            return "1h"
        }
        
    }

    if let minute = components.minute {
        
        if minute >= 2 {
            return "\(minute)m"
        }
        
        if minute >= 1 {
            return "1m"
        }
    }
    
    
    if let seconds = components.second {
        
        return "\(seconds)s"
        
    }

    return "0s"
    
}
