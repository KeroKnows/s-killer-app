import re
from bs4 import BeautifulSoup

KEYWORD = ['Python', 'C', 'C\+\+', 'C#', '.Net', 'Go', 'PHP', 'HTML', 'CSS', 'Java', 'Scala', 'Ruby', 
           'JavaScript', 'JS', 'TypeScript', 'TS', 'Node.js', 'NodeJs', 'Vue', 'React', 
           'gRPC', 'Docker', 'Kubernetes', 
           'SQL', 'MySQL',
           'CI\/CD',
           'Rest API', 'Restful API',
           'Google Cloud', 'Azure', 'AWS']
REGEX = re.compile(rf'(?:[\s,.!?:;])({"|".join(KEYWORD)})(?:[\s,.!?:;])', flags=re.I)

def extract_skillset(description):
    soup = BeautifulSoup(description, features='html.parser')
    text = soup.get_text(separator=' ')
    skills = re.findall(REGEX, text)
    return list(set(skills))

if __name__ == '__main__':
    import yaml
    with open('spec/fixtures/fulljob.yaml', 'r') as f:
        data = f.read()
    data = yaml.safe_load(data)
    skills = map(lambda d: extract_skillset(d['description']), data)
    for idx, skill in enumerate(skills):
        if len(skill) == 0:
            print(data[idx]['description'])
        else: 
            print(skill)