extends RefCounted
class_name NarrativeData

const ROOT := "intro"

const NODES := {
	"intro": {
		"hr": "Prudina miriše na dim i vlagu. Kome prvo vjeruješ?",
		"en": "Prudina smells of smoke and damp stone. Who do you trust first?",
		"choices": [
			{"hr": "Slušaj ljude", "en": "Listen to people", "next": "people_path", "voice": "Empathy", "delta": 1, "thought": "Bodies remember silence."},
			{"hr": "Traži dokumente", "en": "Search documents", "next": "records_path", "voice": "Logic", "delta": 1, "evidence": "Water report copy"},
			{"hr": "Pritisni gradske vlasti", "en": "Pressure the authorities", "next": "authority_path", "voice": "Defiance", "delta": 1}
		]
	},
	"people_path": {
		"hr": "Starica šapuće o otrovanoj vodi i šutnji liječnika.",
		"en": "An old woman whispers about poisoned water and silent doctors.",
		"choices": [
			{"hr": "Zapiši svjedočanstvo", "en": "Record testimony", "next": "crossroads", "evidence": "Witness testimony"},
			{"hr": "Pitaj za ime liječnika", "en": "Ask for doctor's name", "next": "crossroads", "thought": "Truth has legal and emotional versions."}
		]
	},
	"records_path": {
		"hr": "U arhivi nalaziš nedostajuće stranice iz toksikološkog izvješća.",
		"en": "In the archive you find missing pages from a toxicology report.",
		"choices": [
			{"hr": "Sakrij kopiju", "en": "Hide the copy", "next": "crossroads", "voice": "Memory", "delta": 1, "evidence": "Missing report pages"},
			{"hr": "Objavi trag odmah", "en": "Publish clue now", "next": "crossroads", "voice": "Institution", "delta": -1}
		]
	},
	"authority_path": {
		"hr": "Zamjenik gradonačelnika nudi ti nagodbu i tišinu.",
		"en": "Deputy mayor offers you a deal and silence.",
		"choices": [
			{"hr": "Odbij dogovor", "en": "Refuse deal", "next": "crossroads", "voice": "Defiance", "delta": 1},
			{"hr": "Prihvati privremeno", "en": "Accept temporarily", "next": "crossroads", "voice": "Logic", "delta": 1, "thought": "Not all truths survive daylight."}
		]
	},
	"crossroads": {
		"hr": "Dan završava. Svaka odluka pomiče jednu vrstu istine.",
		"en": "Day ends. Every decision shifts a kind of truth.",
		"choices": [
			{"hr": "Nastavi sutra", "en": "Continue tomorrow", "next": "intro"}
		]
	}
}
