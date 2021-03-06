import re

KEYWORD = ['Python', 'C', 'C\+\+', 'C#', '.Net', 'Go', 'PHP', 'HTML', 'CSS', 'Java', 'Scala', 'Ruby', 
           'JavaScript', 'JS', 'TypeScript', 'TS', 'Node.js', 'NodeJs', 'Vue', 'React', 
           'gRPC', 'Docker', 'Kubernetes', 
           'SQL', 'MySQL',
           'CI\/CD',
           'Rest API', 'Restful API',
           'Google Cloud', 'Azure', 'AWS']
REGEX = re.compile(rf'(?:[\s,.!?:;])({"|".join(KEYWORD)})(?:[\s,.!?:;])', flags=re.I)

def extract_skillset(description):
    skills = re.findall(REGEX, description)
    return list(set(skills))

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print(f'[ ERROR ] please specify the file with job description in command line')
        exit(1)
    
    with open(sys.argv[1], 'r') as f:
        description = f.read().strip()
    skillset = extract_skillset(description)
    print(skillset)