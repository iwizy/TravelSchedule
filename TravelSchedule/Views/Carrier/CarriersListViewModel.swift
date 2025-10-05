//
//  CarriersListViewModel.swift
//  TravelSchedule
//
//  ВМ списка перевозчиков

import Foundation

@MainActor
final class CarriersListViewModel: ObservableObject {
    @Published var options: [CarrierOption] = [
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "14 января", depart: "06:15", arrive: "12:05",
            durationText: "5 ч 50 м",
            transferNote: nil,
            email: "info@rzd.ru",
            phoneE164: "+78007750000",
            phoneDisplay: "8 800 775-00-00"
        ),
        CarrierOption(
            carrierName: "ФГК", logoName: "fgk_logo",
            dateText: "15 января", depart: "01:15", arrive: "09:00",
            durationText: "7 ч 45 м",
            transferNote: "С пересадкой в Твери",
            email: "info@railfgk.ru",
            phoneE164: "+78002504777",
            phoneDisplay: "8-800-250-4777"
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "8 ч 30 м",
            transferNote: nil,
            email: "general@ulgroup.ru",
            phoneE164: "+74957838383",
            phoneDisplay: "+7 (495) 783-83-83"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "22:30", arrive: "08:15",
            durationText: "9 ч 45 м",
            transferNote: "С пересадкой в Костроме",
            email: "info@rzd.ru",
            phoneE164: "+78007750000",
            phoneDisplay: "8 800 775-00-00"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "18:05", arrive: "23:15",
            durationText: "5 ч 10 м",
            transferNote: nil,
            email: "info@рzd.ru",
            phoneE164: "+78007750000",
            phoneDisplay: "8 800 775-00-00"
        ),
        CarrierOption(
            carrierName: "РЖД", logoName: "rzd_logo",
            dateText: "17 января", depart: "18:05", arrive: "23:15",
            durationText: "5 ч 10 м",
            transferNote: nil,
            email: "info@рzd.ru",
            phoneE164: "+78007750000",
            phoneDisplay: "8 800 775-00-00"
        ),
        CarrierOption(
            carrierName: "Урал логистика", logoName: "ural_logo",
            dateText: "16 января", depart: "12:30", arrive: "21:00",
            durationText: "8 ч 30 м",
            transferNote: nil,
            email: "general@ulgroup.ru",
            phoneE164: "+74957838383",
            phoneDisplay: "+7 (495) 783-83-83"
        )
    ]

    func decideAvailability(using summary: RouteSummary) async {
        print("ℹ️ [CarriersVM] decideAvailability placeholder for summary=\(summary)")
    }

    func checkAvailabilityReal(apiClient: APIClient, summary: RouteSummary) async {
        print("ℹ️ [CarriersVM] checkAvailabilityReal placeholder")
    }
}
