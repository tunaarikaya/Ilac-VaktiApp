@objc private func saveButtonTapped() {
    guard let name = nameTextField.text, !name.isEmpty else {
        showAlert(title: "Eksik Bilgi", message: "Lütfen ilaç adını girin")
        return
    }
    
    // Get the selected time from timePicker
    let selectedTime = timePicker.date
    
    // Create and save the medication with the selected time
    let ilac = Ilac(context: CoreDataManager.shared.viewContext)
    ilac.ad = name
    
    let ilacKullanim = IlacKullanim(context: CoreDataManager.shared.viewContext)
    ilacKullanim.tarih = selectedTime
    ilacKullanim.ilac = ilac
    
    // Rest of your saving logic...