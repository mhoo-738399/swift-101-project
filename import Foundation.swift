import Foundation

// نموذج بيانات الفيلم باستخدام Struct (يعمل كقاموس داخلي)
struct Movie {
    var rating: Double
    var categories: [String]
}

// قاعدة البيانات الرئيسية: قاموس يربط اسم الفيلم (String) بكائن Movie
var moviesDB: [String: Movie] = [:]

// MARK: - دوال مساعدة للتحقق من صحة الإدخال
func isValidRating(_ input: String) -> Bool {
    guard let rating = Double(input) else { return false }
    return (0...10).contains(rating)
}

func normalizeCategories(_ input: String) -> [String] {
    // تقسيم المدخلات على الفواصل، إزالة المسافات، تحويل أول حرف إلى Capitalized لتوحيدها
    let raw = input.split(separator: ",", omittingEmptySubsequences: true)
    return raw.map { $0.trimmingCharacters(in: .whitespaces).capitalized }
}

// MARK: - دوال العمليات الأساسية
@MainActor
func addMovie() {
    print("\n--- إضافة فيلم جديد ---")
    print("اسم الفيلم: ", terminator: "")
    guard let inputName = readLine()?.trimmingCharacters(in: .whitespaces), !inputName.isEmpty else {
        print("خطأ: اسم الفيلم لا يمكن أن يكون فارغاً.")
        return
    }
    
    // توحيد صيغة الاسم (Capitalized) لضمان عدم التكرار بحروف صغيرة وكبيرة
    let name = inputName.capitalized
    
    if moviesDB[name] != nil {
        print("فيلم '\(name)' موجود مسبقاً. استخدم خيار التعديل.")
        return
    }
    
    print("تقييم الفيلم (0-10): ", terminator: "")
    guard let ratingInput = readLine(), isValidRating(ratingInput) else {
        print("خطأ: التقييم يجب أن يكون رقماً بين 0 و 10.")
        return
    }
    
    print("فئات/تصنيفات الفيلم (افصل بينها بفواصل): ", terminator: "")
    guard let categoriesInput = readLine(), !categoriesInput.trimmingCharacters(in: .whitespaces).isEmpty else {
        print("خطأ: يجب إدخال فئة واحدة على الأقل.")
        return
    }
    let categories = normalizeCategories(categoriesInput)
    guard !categories.isEmpty else {
        print("خطأ: لم يتم التعرف على أي فئة صالحة.")
        return
    }
    
    let rating = Double(ratingInput)!
    moviesDB[name] = Movie(rating: rating, categories: categories)
    print("تمت إضافة الفيلم '\(name)' بنجاح.")
}

@MainActor
func editMovie() {
    print("\n--- تعديل فيلم ---")
    print("أدخل اسم الفيلم الذي تريد تعديله: ", terminator: "")
    guard let inputName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
    
    // البحث بالاسم الموحد
    let name = inputName.capitalized
    guard var movie = moviesDB[name] else {
        print("الفيلم غير موجود.")
        return
    }
    
    print("البيانات الحالية للفيلم '\(name)':")
    print("  التقييم: \(movie.rating)")
    print("  الفئات: \(movie.categories.joined(separator: ", "))")
    
    print("أدخل التقييم الجديد (اتركه فارغاً إذا لم ترد تغييره): ", terminator: "")
    if let newRatingInput = readLine(), !newRatingInput.isEmpty {
        if isValidRating(newRatingInput) {
            movie.rating = Double(newRatingInput)!
        } else {
            print("تقييم غير صالح، لن يتم تغيير التقييم.")
        }
    }
    
    print("أدخل الفئات الجديدة مفصولة بفواصل (اتركه فارغاً إذا لم ترد تغييره): ", terminator: "")
    if let newCatsInput = readLine(), !newCatsInput.isEmpty {
        let newCats = normalizeCategories(newCatsInput)
        if !newCats.isEmpty {
            movie.categories = newCats
        } else {
            print("فئات غير صالحة، لن يتم تغيير الفئات.")
        }
    }
    
    moviesDB[name] = movie
    print("تم تحديث الفيلم '\(name)'.")
}

@MainActor
func deleteMovie() {
    print("\n--- حذف فيلم ---")
    print("أدخل اسم الفيلم الذي تريد حذفه: ", terminator: "")
    guard let inputName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
    
    let name = inputName.capitalized
    guard moviesDB[name] != nil else {
        print("الفيلم غير موجود.")
        return
    }
    moviesDB.removeValue(forKey: name)
    print("تم حذف الفيلم '\(name)'.")
}

@MainActor
func showAllMovies() {
    guard !moviesDB.isEmpty else {
        print("\nلا توجد أفلام في قاعدة البيانات.")
        return
    }
    print("\n=== قائمة جميع الأفلام ===")
    for (name, movie) in moviesDB {
        print("🎬 \(name) | التقييم: \(movie.rating) | الفئات: \(movie.categories.joined(separator: ", "))")
    }
}

// MARK: - دوال البحث والاستعلام
@MainActor
func searchByName() {
    print("\n--- بحث باسم الفيلم ---")
    print("أدخل اسم الفيلم: ", terminator: "")
    guard let inputName = readLine()?.trimmingCharacters(in: .whitespaces) else { return }
    
    let name = inputName.capitalized
    if let movie = moviesDB[name] {
        print("\nاسم الفيلم: \(name)")
        print("التقييم: \(movie.rating)")
        print("الفئات: \(movie.categories.joined(separator: ", "))")
    } else {
        print("لا يوجد فيلم باسم '\(inputName)'.")
    }
}

@MainActor
func searchByCategory() {
    print("\n--- بحث حسب الفئة ---")
    print("أدخل اسم الفئة: ", terminator: "")
    guard let rawCat = readLine()?.trimmingCharacters(in: .whitespaces), !rawCat.isEmpty else {
        print("لم تدخل أي فئة.")
        return
    }
    let category = rawCat.capitalized
    var found: [(name: String, rating: Double)] = []
    
    for (name, movie) in moviesDB {
        // تحويل فئات الفيلم المخزنة للمقارنة بشكل آمن
        let normalizedMovieCategories = movie.categories.map { $0.capitalized }
        if normalizedMovieCategories.contains(category) {
            found.append((name, movie.rating))
        }
    }
    if found.isEmpty {
        print("لا توجد أفلام ضمن فئة '\(rawCat)'.")
    } else {
        print("\nأفلام ضمن فئة '\(category)':")
        for item in found {
            print("  - \(item.name) (تقييم: \(item.rating))")
        }
    }
}

@MainActor
func searchByRatingRange() {
    print("\n--- بحث حسب نطاق التقييم ---")
    print("أدنى تقييم: ", terminator: "")
    guard let minInput = readLine(), let minRating = Double(minInput) else {
        print("خطأ: يجب إدخال رقم صحيح أو عشري.")
        return
    }
    print("أعلى تقييم: ", terminator: "")
    guard let maxInput = readLine(), let maxRating = Double(maxInput) else {
        print("خطأ: يجب إدخال رقم صحيح أو عشري.")
        return
    }
    guard minRating <= maxRating else {
        print("خطأ: الحد الأدنى لا يمكن أن يكون أكبر من الحد الأعلى.")
        return
    }
    
    var found: [(name: String, rating: Double)] = []
    for (name, movie) in moviesDB {
        if movie.rating >= minRating && movie.rating <= maxRating {
            found.append((name, movie.rating))
        }
    }
    if found.isEmpty {
        print("لا توجد أفلام بتقييم بين \(minRating) و \(maxRating).")
    } else {
        print("\nأفلام بتقييم بين \(minRating) و \(maxRating):")
        for item in found {
            print("  - \(item.name) (تقييم: \(item.rating))")
        }
    }
}

func reportProblem() {
    print("\n--- إبلاغ عن مشكلة ---")
    print("إذا واجهت أي خطأ أو اقتراح، يمكنك مراسلة المطور على: support@moviesapp.com")
    print("شكراً لمساعدتنا في تحسين البرنامج.")
}

// MARK: - تحميل البيانات الأولية
@MainActor
func loadInitialData() {
    let initialMovies: [String: (rating: Double, categories: [String])] = [
        "A Beautiful Mind": (8.2, ["Biography", "Drama"]),
        "Finding Nemo": (8.1, ["Animation", "Adventure", "Comedy"]),
        "When a Stranger Calls": (5.1, ["Horror", "Thriller"]),
        "The Pursuit Of Happyness": (8.0, ["Biography", "Drama"]), // تم تعديل الأحرف هنا لتتوافق مع دالة الـ capitalized
        "Inside Out": (8.2, ["Animation", "Adventure", "Comedy"]),
        "Inception": (9.0, ["Drama", "Action", "Adventure"])
    ]
    for (name, data) in initialMovies {
        moviesDB[name.capitalized] = Movie(rating: data.rating, categories: data.categories.map { $0.capitalized })
    }
}

// MARK: - القائمة الرئيسية
@MainActor
func mainMenu() {
    while true {
        print("\n" + String(repeating: "=", count: 50))
        print("        برنامج إدارة مجموعة الأفلام")
        print(String(repeating: "=", count: 50))
        print("1. إضافة فيلم جديد")
        print("2. تعديل فيلم")
        print("3. حذف فيلم")
        print("4. عرض جميع الأفلام")
        print("5. بحث باسم الفيلم")
        print("6. بحث حسب الفئة")
        print("7. بحث حسب نطاق التقييم")
        print("8. إبلاغ عن مشكلة")
        print("9. الخروج من البرنامج")
        print("-" + String(repeating: "-", count: 49))
        
        print("أدخل رقم الخيار: ", terminator: "")
        guard let choice = readLine()?.trimmingCharacters(in: .whitespaces) else { continue }
        
        switch choice {
        case "1": addMovie()
        case "2": editMovie()
        case "3": deleteMovie()
        case "4": showAllMovies()
        case "5": searchByName()
        case "6": searchByCategory()
        case "7": searchByRatingRange()
        case "8": reportProblem()
        case "9": 
            print("شكراً لاستخدام البرنامج. إلى اللقاء!")
            return
        default:
            print("خيار غير صالح. الرجاء إدخال رقم بين 1 و 9.")
        }
    }
}

// MARK: - تشغيل البرنامج
loadInitialData()
mainMenu()