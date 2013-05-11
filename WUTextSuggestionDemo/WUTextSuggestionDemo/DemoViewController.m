//
//  DemoViewController.m
//  WUTextSuggestionDemo
//
//  Created by YuAo on 5/11/13.
//  Copyright (c) 2013 YuAo. All rights reserved.
//

#import "DemoViewController.h"
#import "WUTextSuggestionController.h"
#import "WUTextSuggestionDisplayController.h"

@interface DemoViewController () <WUTextSuggestionDisplayControllerDataSource>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    WUTextSuggestionDisplayController *suggestionDisplayController = [[WUTextSuggestionDisplayController alloc] init];
    suggestionDisplayController.dataSource = self;
    
    WUTextSuggestionController *suggestionController = [[WUTextSuggestionController alloc] initWithTextView:self.textView suggestionDisplayController:suggestionDisplayController];
    suggestionController.suggestionType = WUTextSuggestionTypeAt | WUTextSuggestionTypeHashTag;
}

#pragma mark - WUTextSuggestionDisplayControllerDataSource

- (NSArray *)textSuggestionDisplayController:(WUTextSuggestionDisplayController *)textSuggestionDisplayController suggestionDisplayItemsForSuggestionType:(WUTextSuggestionType)suggestionType query:(NSString *)suggestionQuery
{
    if (suggestionType == WUTextSuggestionTypeAt) {
        NSMutableArray *suggestionDisplayItems = [NSMutableArray array];
        for (NSString *name in [self filteredNamesUsingQuery:suggestionQuery]) {
            WUTextSuggestionDisplayItem *item = [[WUTextSuggestionDisplayItem alloc] initWithTitle:name];
            [suggestionDisplayItems addObject:item];
        }
        return [suggestionDisplayItems copy];
    }
    
    if (suggestionType == WUTextSuggestionTypeHashTag) {
        NSMutableArray *suggestionDisplayItems = [NSMutableArray array];
        for (NSString *tag in [self filteredTagsUsingQuery:suggestionQuery]) {
            WUTextSuggestionDisplayItem *item = [[WUTextSuggestionDisplayItem alloc] initWithTitle:tag];
            [suggestionDisplayItems addObject:item];
        }
        return [suggestionDisplayItems copy];
    }
    return nil;
}

/* You can use async callback
 
- (void)textSuggestionDisplayController:(WUTextSuggestionDisplayController *)textSuggestionDisplayController suggestionDisplayItemsForSuggestionType:(WUTextSuggestionType)suggestionType query:(NSString *)suggestionQuery callback:(void (^)(NSArray *))gotSuggestionDisplayItemsBlock {
    dispatch_queue_t queryQueue = dispatch_queue_create("com.wutextsuggestion.query", DISPATCH_QUEUE_SERIAL);
    dispatch_async(queryQueue, ^{
        if (suggestionType == WUTextSuggestionTypeAt) {
            NSMutableArray *suggestionDisplayItems = [NSMutableArray array];
            for (NSString *name in [self filteredNamesUsingQuery:suggestionQuery]) {
                WUTextSuggestionDisplayItem *item = [[WUTextSuggestionDisplayItem alloc] initWithTitle:name];
                [suggestionDisplayItems addObject:item];
            }
            gotSuggestionDisplayItemsBlock(suggestionDisplayItems);
        }
    });
}
 
*/

#pragma mark - names

- (NSArray *)filteredNamesUsingQuery:(NSString *)query {
    NSArray *filteredNames = [self.names filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[evaluatedObject lowercaseString] hasPrefix:[query lowercaseString]]) {
            return YES;
        } else {
            return NO;
        }
    }]];
    return filteredNames;
}

- (NSArray *)names {
    return @[@"Abigail",@"Ada",@"Adela",@"Adelaide",@"Afra",@"Agatha",@"Agnes",@"Alberta",@"Alexia",@"Alice",@"Alma",@"Althea",@"Alva",@"Amanda",@"Amelia",@"Amy",@"Anastasia",@"Andrea",@"Angela",@"Ann",@"Anna",@"Annabelle",@"Antonia",@"April",@"Arabela",@"Arlene",@"Astrid",@"Atalanta",@"Athena",@"Audrey",@"Aurora",@"Barbara",@"Beatrice",@"Belinda",@"Bella",@"Belle",@"Bernice",@"Bertha",@"Beryl",@"Bess",@"Betsy",@"Betty",@"Beulah",@"Beverly",@"Blanche",@"Bblythe",@"Bonnie",@"Breenda",@"Bridget",@"Brook",@"Camille",@"Candance",@"Candice",@"Cara",@"Carol",@"Caroline",@"Catherine",@"Cathy",@"Cecilia",@"Celeste",@"Charlotte",@"Cherry",@"Cheryl",@"Chloe",@"Christine",@"Claire",@"Clara",@"Clementine",@"Constance",@"Cora",@"Coral",@"Cornelia",@"Crystal",@"Cynthia",@"Daisy",@"Dale",@"Dana",@"Daphne",@"Darlene",@"Dawn",@"Debby",@"Deborah",@"Deirdre",@"Delia",@"Denise",@"Diana",@"Dinah",@"Dolores",@"Dominic",@"Donna",@"Dora",@"Doreen",@"Doris",@"Dorothy",@"Eartha",@"Eden",@"Edith",@"Edwina",@"Eileen",@"Elaine",@"Eleanore",@"Elizabeth",@"Ella",@"Ellen",@"Elma",@"Elsa",@"Elsie",@"Elva",@"Elvira",@"Emily",@"Emma",@"Enid",@"Erica",@"Erin",@"Esther",@"Ethel",@"Eudora",@"Eunice",@"Evangeline",@"Eve",@"Evelyn",@"Faithe",@"Fanny",@"Fay",@"Flora",@"Florence",@"Frances",@"Freda",@"Frederica",@"Gabrielle",@"Gail",@"Gemma",@"Genevieve",@"Georgia",@"Geraldine",@"Gill",@"Giselle",@"Gladys",@"Gloria",@"Grace",@"Griselda",@"Gustave",@"Gwendolyn",@"Hannah",@"Harriet",@"Hazel",@"Heather",@"Hedda",@"Hedy",@"Helen",@"Heloise",@"Hermosa",@"Hilda",@"Hilary",@"Honey",@"Hulda",@"Ida",@"Ina",@"Ingrid",@"Irene",@"Iris",@"Irma",@"Isabel",@"Ivy",@"Jacqueline",@"Jamie",@"Jane",@"Janet",@"Janice",@"Jean",@"Jennifer",@"Jenny",@"Jessie",@"Jessica",@"Jill",@"Jo",@"Joa",@"Joanna",@"Joanne",@"Jocelyn",@"Jodie",@"Josephine",@"Joy",@"Joyce",@"Judith",@"Judy",@"Julia",@"Julie",@"Juliet",@"June",@"Kama",@"Karen",@"Katherine",@"Kay",@"Kelly",@"Kimberley",@"Kitty",@"Kristin",@"Laura",@"Laurel",@"Lauren",@"Lee",@"Leila",@"Lena",@"Leona",@"Lesley",@"Letitia",@"Lilith",@"Lillian",@"Linda",@"Lindsay",@"Lisa",@"Liz",@"Lorraine",@"Louise",@"Lucy",@"Lydia",@"Lynn",@"Mabel",@"Madeline",@"Madge",@"Maggie",@"Mamie",@"Mandy",@"Marcia",@"Margaret",@"Marguerite",@"Maria",@"Marian",@"Marina",@"Marjorie",@"Martha",@"Martina",@"Mary",@"Maud",@"Maureen",@"Mavis",@"Maxine",@"Mag",@"May",@"Megan",@"Melissa",@"Meroy",@"Meredith",@"Merry",@"Michelle",@"Michaelia",@"Mignon",@"Mildred",@"Mirabelle",@"Miranda",@"Miriam",@"Modesty",@"Moira",@"Molly",@"Mona",@"Monica",@"Muriel",@"Murray",@"Myra",@"Myrna",@"Nancy",@"Naomi",@"Natalie",@"Natividad",@"Nelly",@"Nicola",@"Nicole",@"Nina",@"Nora",@"Norma",@"Novia",@"Nydia",@"Octavia",@"Odelette",@"Odelia",@"Olga",@"Olive",@"Olivia",@"Ophelia",@"Pag",@"Page",@"Pamela",@"Pandora",@"Patricia",@"Paula",@"Pearl",@"Penelope",@"Penny",@"Philipppa",@"Phoebe",@"Phoenix",@"Phyllis",@"Polly",@"Poppy",@"Prima",@"Priscilla",@"Prudence",@"Queena",@"Quintina",@"Rachel",@"Rae",@"Rebecca",@"Regina",@"Renata",@"Renee",@"Rita",@"Riva",@"Roberta",@"Rosalind",@"Rose",@"Rosemary",@"Roxanne",@"Ruby",@"Ruth",@"Sabina",@"Sally",@"Sabrina",@"Salome",@"Samantha",@"Sandra",@"Sandy",@"Sara",@"Sarah",@"Sebastiane",@"Selena",@"Sharon",@"Sheila",@"Sherry",@"Shirley",@"Sibyl",@"Sigrid",@"Simona",@"Sophia",@"Spring",@"Stacey",@"Setlla",@"Stephanie",@"Susan",@"Susanna",@"Susie",@"Suzanne",@"Sylvia",@"Tabitha",@"Tammy",@"Teresa",@"Tess",@"Thera",@"Theresa",@"Tiffany",@"Tina",@"Tobey",@"Tracy",@"Trista",@"Truda",@"Ula",@"Una",@"Ursula",@"Valentina",@"Valerie",@"Vanessa",@"Venus",@"Vera",@"Verna",@"Veromca",@"Veronica",@"Victoria",@"Vicky",@"Viola",@"Violet",@"Virginia",@"Vita",@"Vivien",@"Wallis",@"Wanda",@"Wendy",@"Winifred",@"Winni",@"Xanthe",@"Xaviera",@"Xenia",@"Yedda",@"Yetta",@"Yvette",@"Yvonne",@"Zara",@"Zenobia",@"Zoe",@"Zona",@"Zora"];
}

- (NSArray *)filteredTagsUsingQuery:(NSString *)query {
    NSArray *filteredTags = [self.tags filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[evaluatedObject lowercaseString] hasPrefix:[query lowercaseString]]) {
            return YES;
        } else {
            return NO;
        }
    }]];
    return filteredTags;
}

- (NSArray *)tags {
    return @[@"HappyMothersDay",@"Apple",@"CleanSlate",@"HashTag",@"HelloWorld",@"ChangeOrDie",@"Caelondia"];
}

@end
